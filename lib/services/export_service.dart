import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import '../models/sale.dart';

class ExportService {
  Future<void> exportSaleToPdf(Sale sale) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('StockLite POS Receipt', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Sale ID: ${sale.id ?? "Pending"}'),
              pw.Text('Date: ${sale.date ?? DateTime.now().toString()}'),
              pw.Text('Client ID: ${sale.clientId ?? "Walk-in"}'),
              pw.Divider(),
              pw.ListView.builder(
                itemCount: sale.items.length,
                itemBuilder: (context, index) {
                  final item = sale.items[index];
                  return pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(item.product?.name ?? 'Product ${item.productId}'),
                      pw.Text('${item.quantity} x \$${item.price}'),
                      pw.Text('\$${(item.quantity * item.price).toStringAsFixed(2)}'),
                    ],
                  );
                },
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('\$${sale.total.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          );
        },
      ),
    );

    if (kIsWeb) {
      // Web download logic (omitted for brevity, requires dart:html or universal_html)
      print('PDF Export not fully supported on Web in this demo');
    } else {
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/sale_${sale.id ?? "temp"}.pdf');
      await file.writeAsBytes(await pdf.save());
      await OpenFile.open(file.path);
    }
  }

  Future<void> exportSalesToCsv(List<Sale> sales) async {
    List<List<dynamic>> rows = [];
    rows.add(["ID", "Date", "Client ID", "Total", "Synced"]);

    for (var sale in sales) {
      rows.add([
        sale.id,
        sale.date,
        sale.clientId,
        sale.total,
        sale.synced == 1 ? "Yes" : "No"
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    if (kIsWeb) {
      print('CSV Export not fully supported on Web in this demo');
    } else {
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/sales_report.csv');
      await file.writeAsString(csv);
      await OpenFile.open(file.path);
    }
  }
}
