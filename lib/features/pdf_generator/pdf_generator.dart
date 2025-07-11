import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfGenerator {
  static Future<void> generateMonthlyPdf(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    pw.ImageProvider? logo;
    try {
      final logoData = await rootBundle.load('assets/images/logo.png');
      logo = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (_) {
      logo = null;
    }

    final expenseBreakdown = data['breakdown'] as List<dynamic>;
    final total = data['total_expenses'] as num;
    final colorList = [
      PdfColors.red,
      PdfColors.green,
      PdfColors.blue,
      PdfColors.orange,
      PdfColors.purple,
      PdfColors.brown,
    ];

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(24),
        header: (ctx) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            if (logo != null) pw.Image(logo, width: 40),
            pw.Text(
              'CashCare Report - ${data["month"]}',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
        build: (context) => [
          pw.SizedBox(height: 12),
          pw.Text('📅 Monthly Summary', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Text('Income: Rs ${data["total_income"]}'),
          pw.Text('Expenses: Rs ${data["total_expenses"]}'),
          pw.Text('Remaining: Rs ${data["remaining"]}', style: pw.TextStyle(color: PdfColors.green800)),

          pw.SizedBox(height: 20),
          pw.Text('📊 Expense Breakdown:', style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
          ...List.generate(expenseBreakdown.length, (i) {
            final item = expenseBreakdown[i];
            final percent = (item["amount"] / total) * 100;
            return pw.Row(
              children: [
                pw.Container(width: 10, height: 10, color: colorList[i % colorList.length]),
                pw.SizedBox(width: 8),
                pw.Text('${item["category"]}: Rs ${item["amount"]} (${percent.toStringAsFixed(1)}%)'),
              ],
            );
          }),

          pw.SizedBox(height: 20),
          pw.Text('💸 Top Transactions:', style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Table.fromTextArray(
            headers: ['Title', 'Amount', 'Date'],
            data: List<List<String>>.from(data["top_transactions"].map((txn) => [
              txn["title"].toString(),
              "Rs ${txn["amount"]}",
              txn["date"].toString()
            ])),
            border: pw.TableBorder.all(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'CashCare_Report_${data["month"]}.pdf',
    );

  }
}
