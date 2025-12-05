import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../models/sale.dart';

class SaleDetailPage extends StatelessWidget {
  final Sale sale;

  const SaleDetailPage({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de Venta #${sale.id}'),
      ),
      body: PdfPreview(
        build: (format) => _generatePdf(format),
        canChangeOrientation: false,
        canChangePageFormat: false,
        allowSharing: true,
        allowPrinting: true,
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'StockLite POS',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Divider(),
              pw.SizedBox(height: 16),
              pw.Text('Venta ID: ${sale.id}'),
              pw.Text('Fecha: ${sale.date ?? "Desconocida"}'),
              pw.SizedBox(height: 16),
              pw.Text('Productos:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.ListView.builder(
                itemCount: sale.items.length,
                itemBuilder: (context, index) {
                  final item = sale.items[index];
                  return pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(item.product?.name ?? 'Producto'),
                      pw.Text('${item.quantity} x \$${item.price.toStringAsFixed(2)}'),
                      pw.Text('\$${(item.quantity * item.price).toStringAsFixed(2)}'),
                    ],
                  );
                },
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                  pw.Text('\$${sale.total.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
