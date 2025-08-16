import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfGenerator {
  static Future<void> generateMonthlyPdf(Map<String, dynamic> data) async {
    final pdf = pw.Document();
    final logo = await _loadLogo();

    const primaryGreen = PdfColor.fromInt(0xFF1B5E20);
    const accentGreen = PdfColor.fromInt(0xFF4CAF50);
    const textColor = PdfColors.grey800;
    const lightTextColor = PdfColors.grey600;
    const borderColor = PdfColors.grey300;

    final reports = data['monthly_reports'] ?? [data];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginBottom: 36,
          marginTop: 48,
          marginLeft: 36,
          marginRight: 36,
        ),
        header: (ctx) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Row(
              children: [
                if (logo != null)
                  pw.Container(
                    margin: const pw.EdgeInsets.only(right: 10),
                    height: 50,
                    width: 50,
                    child: pw.Image(logo),
                  ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'CashCare Insights',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryGreen,
                      ),
                    ),
                    pw.Text(
                      'Financial Overview Report',
                      style: pw.TextStyle(fontSize: 12, color: lightTextColor),
                    ),
                  ],
                ),
              ],
            ),
            pw.Text(
              'Date: ${DateTime.now().toLocal().toString().split(' ')[0]}',
              style: pw.TextStyle(fontSize: 10, color: lightTextColor),
            ),
          ],
        ),
        footer: (ctx) => pw.Text(
          'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
          style: pw.TextStyle(fontSize: 10, color: lightTextColor),
        ),
        build: (context) => [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              for (final monthData in reports) ...[
                _sectionTitle(
                  "Report Summary for ${monthData['month'] ?? monthData['quarter'] ?? monthData['year'] ?? 'Selected Period'}",
                  primaryGreen,
                ),
                pw.SizedBox(height: 15),
                _summaryCards(
                  _toDouble(monthData['total_income']),
                  _toDouble(monthData['total_expenses']),
                  _toDouble(monthData['remaining']),
                  primaryGreen,
                  accentGreen,
                ),
                pw.SizedBox(height: 25),
                _sectionTitle('Expense Breakdown', primaryGreen),
                pw.SizedBox(height: 15),
                _expenseBreakdown(
                  monthData['breakdown'] as List<dynamic>?,
                  _toDouble(monthData['total_expenses']),
                  textColor,
                ),
                pw.SizedBox(height: 25),
                _sectionTitle('Top Transactions', primaryGreen),
                pw.SizedBox(height: 15),
                _transactionsTable(
                  monthData['top_transactions'] as List<dynamic>?,
                  primaryGreen,
                  textColor,
                  borderColor,
                ),
                if (reports.indexOf(monthData) < reports.length - 1)
                  pw.NewPage(),
              ],
            ],
          ),
        ],
      ),
    );

    final fileName =
        "CashCare_Report_${data['month'] ?? data['quarter'] ?? data['year'] ?? 'Period'}.pdf";
    await Printing.sharePdf(bytes: await pdf.save(), filename: fileName);
  }

  static double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  static pw.Widget _sectionTitle(String text, PdfColor color) => pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border(left: pw.BorderSide(color: color, width: 5)),
    ),
    padding: const pw.EdgeInsets.only(left: 10, bottom: 5),
    child: pw.Text(
      text,
      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: color),
    ),
  );

  static pw.Widget _summaryCards(double income, double expenses, double remaining,
      PdfColor primaryColor, PdfColor accentColor) =>
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _summaryCard('Total Income', 'Rs ${income.toStringAsFixed(2)}', primaryColor, PdfColors.green),
          _summaryCard('Total Expenses', 'Rs ${expenses.toStringAsFixed(2)}', primaryColor, PdfColors.red),
          _summaryCard('Net Remaining', 'Rs ${remaining.toStringAsFixed(2)}', primaryColor, accentColor),
        ],
      );

  static pw.Widget _summaryCard(
      String title, String value, PdfColor primaryColor, PdfColor valueColor) =>
      pw.Expanded(
        child: pw.Container(
          margin: const pw.EdgeInsets.symmetric(horizontal: 5),
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(color: PdfColors.white, borderRadius: pw.BorderRadius.circular(8)),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(title,
                  style: pw.TextStyle(fontSize: 12, color: primaryColor, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text(value,
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: valueColor)),
            ],
          ),
        ),
      );

  static pw.Widget _expenseBreakdown(List<dynamic>? breakdown, double totalExpenses, PdfColor textColor) {
    if (breakdown == null || breakdown.isEmpty) {
      return pw.Text('No expenses recorded for breakdown.', style: pw.TextStyle(color: textColor));
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: breakdown.map((item) {
        final amount = _toDouble(item['amount']);
        final percent = totalExpenses > 0 ? (amount / totalExpenses) * 100 : 0;
        return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Text(
            '${item['category']}: Rs ${amount.toStringAsFixed(2)} (${percent.toStringAsFixed(1)}%)',
            style: pw.TextStyle(fontSize: 11, color: textColor),
          ),
        );
      }).toList(),
    );
  }

  static pw.Widget _transactionsTable(List<dynamic>? transactions, PdfColor primaryColor, PdfColor textColor,
      PdfColor borderColor) {
    if (transactions == null || transactions.isEmpty) {
      return pw.Text('No transactions recorded.', style: pw.TextStyle(color: textColor));
    }

    return pw.Table.fromTextArray(
      headers: ['Title', 'Amount', 'Date'],
      data: transactions.map((txn) {
        final amount = _toDouble(txn['amount']);
        final date = txn['date'].toString().split(' ')[0];
        return [txn['title'].toString(), "Rs ${amount.toStringAsFixed(2)}", date];
      }).toList(),
      border: pw.TableBorder.all(color: borderColor, width: 1),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
      headerDecoration: pw.BoxDecoration(color: primaryColor),
      cellStyle: pw.TextStyle(fontSize: 9, color: textColor),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.all(8),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
      },
    );
  }

  static Future<pw.ImageProvider?> _loadLogo() async {
    try {
      final data = await rootBundle.load('assets/images/logo.png');
      return pw.MemoryImage(data.buffer.asUint8List());
    } catch (e) {
      print('Error loading logo: $e');
      return null;
    }
  }
}
