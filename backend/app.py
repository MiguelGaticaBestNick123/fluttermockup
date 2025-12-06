import os
import base64
import uuid
from datetime import datetime

from flask import Flask, request, jsonify, send_from_directory
from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash
from flask_cors import CORS
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
from dotenv import load_dotenv

# Cargar variables de entorno (si no, no funciona nada jaja)
load_dotenv()

# ------------------ CONFIGURACIÓN ------------------
# Aquí configuramos Flask y la base de datos, todo chill 8)
app = Flask(__name__)
CORS(app)

app.config["SQLALCHEMY_DATABASE_URI"] = os.getenv("SQLALCHEMY_DATABASE_URI", "sqlite:///figures.db")
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
app.config["JWT_SECRET_KEY"] = os.getenv("SECRET_KEY", "fallback-secret-key")

UPLOAD_DIR = os.path.join(os.path.dirname(__file__), "uploads")
os.makedirs(UPLOAD_DIR, exist_ok=True)

db = SQLAlchemy(app)
jwt = JWTManager(app)

# ------------------ MODELOS DE LA DB ------------------
# Definimos las tablas, ojalá no cambien mucho los requerimientos :p
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password_hash = db.Column(db.String(128), nullable=False)
    role = db.Column(db.String(20), default="operator") # admin, operator

    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

class Product(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(180), nullable=False)
    description = db.Column(db.Text, nullable=True)
    price = db.Column(db.Float, nullable=False, default=0.0)
    stock = db.Column(db.Integer, nullable=False, default=0)
    barcode = db.Column(db.String(50), unique=True, nullable=True)
    image_filename = db.Column(db.String(255), nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)

    def to_dict(self):
        root = request.url_root.rstrip('/')
        img_url = f"{root}/uploads/{self.image_filename}" if self.image_filename else None
        return {
            "id": self.id,
            "name": self.name,
            "description": self.description,
            "price": self.price,
            "stock": self.stock,
            "barcode": self.barcode,
            "image_url": img_url,
            "created_at": self.created_at.isoformat()
        }

class Client(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(120), nullable=True)
    phone = db.Column(db.String(20), nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            "id": self.id,
            "name": self.name,
            "email": self.email,
            "phone": self.phone,
            "created_at": self.created_at.isoformat()
        }

class Sale(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    client_id = db.Column(db.Integer, db.ForeignKey('client.id'), nullable=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    total = db.Column(db.Float, nullable=False)
    date = db.Column(db.DateTime, default=datetime.utcnow)
    items = db.relationship('SaleItem', backref='sale', lazy=True)

    def to_dict(self):
        return {
            "id": self.id,
            "client_id": self.client_id,
            "user_id": self.user_id,
            "total": self.total,
            "date": self.date.isoformat(),
            "items": [i.to_dict() for i in self.items]
        }

class SaleItem(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    sale_id = db.Column(db.Integer, db.ForeignKey('sale.id'), nullable=False)
    product_id = db.Column(db.Integer, db.ForeignKey('product.id'), nullable=False)
    quantity = db.Column(db.Integer, nullable=False)
    price = db.Column(db.Float, nullable=False) # Price at the moment of sale

    def to_dict(self):
        return {
            "product_id": self.product_id,
            "quantity": self.quantity,
            "price": self.price
        }

# inicializar DB y crear usuario admin si no existe (para no quedarnos fuera :v)
with app.app_context():
    db.create_all()
    if not User.query.filter_by(username="admin").first():
        admin = User(username="admin", role="admin")
        admin.set_password("secret")
        db.session.add(admin)
        db.session.commit()
        print("Admin user created: admin/secret")

# ------------------ RUTAS / ENDPOINTS ------------------
# Aquí empieza la magia de la API

@app.route("/login", methods=["POST"])
def login():
    data = request.get_json(silent=True) or {}
    username = data.get("username")
    password = data.get("password")

    if not username or not password:
        return jsonify({"msg": "Missing username or password"}), 400

    user = User.query.filter_by(username=username).first()
    if user and user.check_password(password):
        access_token = create_access_token(identity=username, additional_claims={"role": user.role})
        return jsonify(access_token=access_token, role=user.role), 200
    
    return jsonify({"msg": "Bad username or password"}), 401

@app.route("/register", methods=["POST"])
def register():
    data = request.get_json(silent=True) or {}
    username = data.get("username")
    password = data.get("password")
    role = data.get("role", "operator")

    if not username or not password:
        return jsonify({"msg": "Missing username or password"}), 400

    if User.query.filter_by(username=username).first():
        return jsonify({"msg": "Username already exists"}), 400

    new_user = User(username=username, role=role)
    new_user.set_password(password)
    db.session.add(new_user)
    db.session.commit()

    return jsonify({"msg": "User created successfully"}), 201

# --- Productos (Lo que vendemos) ---
@app.route("/api/products", methods=["GET"])
@jwt_required()
def list_products():
    items = Product.query.order_by(Product.id.desc()).all()
    return jsonify([i.to_dict() for i in items]), 200

@app.route("/api/products", methods=["POST"])
@jwt_required()
def create_product():
    data = request.get_json(silent=True) or {}
    name = (data.get("name") or "").strip()
    price = data.get("price", 0.0)
    stock = data.get("stock", 0)
    barcode = data.get("barcode")
    
    if not name:
        return jsonify({"error": "Name is required"}), 400

    # Manejo de imagen, si viene en base64 la guardamos
    # espero que no manden archivos muy pesados...
    img_b64 = data.get("image_base64")
    filename = data.get("image_filename")
    safe_name = None

    if img_b64 and filename:
        try:
            raw = base64.b64decode(img_b64, validate=True)
            ext = os.path.splitext(filename)[1].lower()
            if ext not in [".jpg", ".jpeg", ".png", ".webp"]:
                ext = ".jpg"
            safe_name = f"{uuid.uuid4().hex}{ext}"
            path = os.path.join(UPLOAD_DIR, safe_name)
            with open(path, "wb") as f:
                f.write(raw)
        except Exception:
            pass # Si falla la imagen, pues ni modo, se queda sin foto :v

    prod = Product(
        name=name,
        description=data.get("description"),
        price=price,
        stock=stock,
        barcode=barcode,
        image_filename=safe_name
    )
    db.session.add(prod)
    db.session.commit()

    return jsonify(prod.to_dict()), 201

@app.route("/api/products/<int:id>", methods=["PUT"])
@jwt_required()
def update_product(id):
    prod = Product.query.get(id)
    if not prod:
        return jsonify({"error": "Product not found"}), 404
    
    data = request.get_json(silent=True) or {}
    if "name" in data:
        prod.name = data["name"]
    if "description" in data:
        prod.description = data["description"]
    if "price" in data:
        prod.price = data["price"]
    if "stock" in data:
        prod.stock = data["stock"]
    if "barcode" in data:
        prod.barcode = data["barcode"]
    
    db.session.commit()
    return jsonify(prod.to_dict()), 200

@app.route("/api/products/<int:id>", methods=["DELETE"])
@jwt_required()
def delete_product(id):
    prod = Product.query.get(id)
    if not prod:
        return jsonify({"error": "Product not found"}), 404
    
    db.session.delete(prod)
    db.session.commit()
    return jsonify({"msg": "Product deleted"}), 200

# --- CLIENTES (Los que pagan) ---
@app.route("/api/clients", methods=["GET"])
@jwt_required()
def list_clients():
    items = Client.query.order_by(Client.name).all()
    return jsonify([i.to_dict() for i in items]), 200

@app.route("/api/clients", methods=["POST"])
@jwt_required()
def create_client():
    data = request.get_json(silent=True) or {}
    name = data.get("name")
    if not name:
        return jsonify({"error": "Name is required"}), 400
    
    # Fix para el error de clave duplicada: calculamos el ID a mano
    # Porque a veces la secuencia de la DB se marea xD
    max_id = db.session.query(db.func.max(Client.id)).scalar() or 0
    client = Client(id=max_id + 1, name=name, email=data.get("email"), phone=data.get("phone"))
    
    db.session.add(client)
    db.session.commit()
    return jsonify(client.to_dict()), 201

@app.route("/api/clients/<int:id>", methods=["PUT"])
@jwt_required()
def update_client(id):
    client = Client.query.get(id)
    if not client:
        return jsonify({"error": "Client not found"}), 404
    
    data = request.get_json(silent=True) or {}
    if "name" in data:
        client.name = data["name"]
    if "email" in data:
        client.email = data["email"]
    if "phone" in data:
        client.phone = data["phone"]
    
    db.session.commit()
    return jsonify(client.to_dict()), 200

@app.route("/api/clients/<int:id>", methods=["DELETE"])
@jwt_required()
def delete_client(id):
    client = Client.query.get(id)
    if not client:
        return jsonify({"error": "Client not found"}), 404
    
    db.session.delete(client)
    db.session.commit()
    return jsonify({"msg": "Client deleted"}), 200

# --- Ventas (Money money money) ---
@app.route("/api/sales", methods=["POST"])
@jwt_required()
def create_sale():
    current_user = get_jwt_identity()
    user = User.query.filter_by(username=current_user).first()
    
    data = request.get_json(silent=True) or {}
    items_data = data.get("items", [])
    client_id = data.get("client_id")
    
    if not items_data:
        return jsonify({"error": "No items in sale"}), 400

    total = 0.0
    sale = Sale(user_id=user.id, client_id=client_id, total=0)
    db.session.add(sale)
    db.session.flush() # Necesitamos el ID de la venta YA, así que flush :p

    for item in items_data:
        product = Product.query.get(item["product_id"])
        if not product:
            continue
        
        qty = item["quantity"]
        price = product.price # Precio actual
        total += price * qty
        
        sale_item = SaleItem(sale_id=sale.id, product_id=product.id, quantity=qty, price=price)
        db.session.add(sale_item)
        
        # Actualizar stock (restamos lo que se vendió)
        product.stock -= qty

    sale.total = total
    db.session.commit()

    return jsonify(sale.to_dict()), 201

@app.route("/uploads/<path:fname>")
def serve_upload(fname):
    return send_from_directory(UPLOAD_DIR, fname, as_attachment=False)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
