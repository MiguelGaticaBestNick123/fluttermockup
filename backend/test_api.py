import requests

BASE_URL = "http://localhost:5000"

def test_api():
    print("Testing API...")

    # 1. Test protected route without token (should fail)
    try:
        r = requests.get(f"{BASE_URL}/api/figures")
        if r.status_code == 401:
            print("PASS: Protected route denied without token")
        else:
            print(f"FAIL: Protected route returned {r.status_code}")
    except Exception as e:
        print(f"FAIL: Connection error {e}")

    # 2. Login (should succeed)
    token = None
    try:
        r = requests.post(f"{BASE_URL}/login", json={"username": "admin", "password": "secret"})
        if r.status_code == 200:
            token = r.json().get("access_token")
            print("PASS: Login successful")
        else:
            print(f"FAIL: Login returned {r.status_code}")
    except Exception as e:
        print(f"FAIL: Connection error {e}")

    if not token:
        print("Skipping authenticated tests due to login failure")
        return

    # 3. Test protected route with token (should succeed)
    try:
        headers = {"Authorization": f"Bearer {token}"}
        r = requests.get(f"{BASE_URL}/api/figures", headers=headers)
        if r.status_code == 200:
            print("PASS: Protected route accessed with token")
        else:
            print(f"FAIL: Protected route returned {r.status_code} with token")
    except Exception as e:
        print(f"FAIL: Connection error {e}")

if __name__ == "__main__":
    test_api()
