import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfGenerator {
  static Future<void> generateMonthlyPdf(Map<String, dynamic> data) async {
    final pdf = pw.Document();
    final pw.ImageProvider? logo = await _loadLogo();

    const PdfColor primaryGreen = PdfColor.fromInt(0xFF1B5E20);
    const PdfColor accentGreen = PdfColor.fromInt(0xFF4CAF50);
    const PdfColor textColor = PdfColors.grey800;
    const PdfColor lightTextColor = PdfColors.grey600;
    const PdfColor borderColor = PdfColors.grey300;

    final List<dynamic> reports = data['monthly_reports'] ?? [data];

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
                _buildSectionTitle("Report Summary for ${monthData['month'] ?? monthData['quarter'] ?? monthData['year'] ?? 'Selected Period'}", primaryGreen),
                pw.SizedBox(height: 15),
                _buildSummaryCards(
                  monthData['total_income'] ?? 0,
                  monthData['total_expenses'] ?? 0,
                  monthData['remaining'] ?? 0,
                  primaryGreen,
                  accentGreen,
                ),
                pw.SizedBox(height: 25),
                _buildSectionTitle('Expense Breakdown', primaryGreen),
                pw.SizedBox(height: 15),
                _buildExpenseBreakdown(
                  monthData['breakdown'] as List<dynamic>?,
                  monthData['total_expenses'] ?? 0,
                  textColor,
                ),
                pw.SizedBox(height: 25),
                _buildSectionTitle('Top Transactions', primaryGreen),
                pw.SizedBox(height: 15),
                _buildTransactionsTable(
                  monthData["top_transactions"] as List<dynamic>?,
                  primaryGreen,
                  textColor,
                  borderColor,
                ),
                pw.SizedBox(height: 30),
                if (reports.indexOf(monthData) < reports.length - 1)
                  pw.NewPage(),
              ],
            ],
          ),
        ],
      ),
    );

    final fileName = "CashCare_Report_${data['month'] ?? data['quarter'] ?? data['year'] ?? 'Period'}.pdf";
    await Printing.sharePdf(bytes: await pdf.save(), filename: fileName);
  }

  static pw.Widget _buildSectionTitle(String title, PdfColor color) {
    return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border(left: pw.BorderSide(color: color, width: 5))),
      padding: const pw.EdgeInsets.only(left: 10, bottom: 5),
      child: pw.Text(
        title,
        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: color),
      ),
    );
  }

  static pw.Widget _buildSummaryCards(
      double income, double expenses, double remaining, PdfColor primaryColor, PdfColor accentColor) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
      children: [
        _buildSummaryCard('Total Income', 'Rs ${income.toStringAsFixed(2)}', primaryColor, PdfColors.green),
        _buildSummaryCard('Total Expenses', 'Rs ${expenses.toStringAsFixed(2)}', primaryColor, PdfColors.red),
        _buildSummaryCard('Net Remaining', 'Rs ${remaining.toStringAsFixed(2)}', primaryColor, accentColor),
      ],
    );
  }

  static pw.Widget _buildSummaryCard(String title, String value, PdfColor primaryColor, PdfColor valueColor) {
    return pw.Expanded(
      child: pw.Container(
        margin: const pw.EdgeInsets.symmetric(horizontal: 5),
        padding: const pw.EdgeInsets.all(15),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: pw.BorderRadius.circular(8),
          boxShadow: [
            pw.BoxShadow(color: PdfColors.grey200, blurRadius: 5, offset: const PdfPoint(0, 2)),
          ],
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(title, style: pw.TextStyle(fontSize: 12, color: primaryColor, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text(value, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: valueColor)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildExpenseBreakdown(
      List<dynamic>? breakdown, double totalExpenses, PdfColor textColor) {
    if (breakdown == null || breakdown.isEmpty) {
      return pw.Text('No expenses recorded for breakdown.', style: pw.TextStyle(color: textColor));
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: breakdown.map((item) {
        final amount = item['amount'] ?? 0;
        final percentage = totalExpenses > 0 ? (amount / totalExpenses) * 100 : 0;
        return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Text(
            '${item['category']}: Rs ${amount.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
            style: pw.TextStyle(fontSize: 11, color: textColor),
          ),
        );
      }).toList(),
    );
  }

  static pw.Widget _buildTransactionsTable(
      List<dynamic>? transactions, PdfColor primaryColor, PdfColor textColor, PdfColor borderColor) {
    if (transactions == null || transactions.isEmpty) {
      return pw.Text('No transactions recorded.', style: pw.TextStyle(color: textColor));
    }

    return pw.Table.fromTextArray(
      headers: ['Title', 'Amount', 'Date'],
      data: transactions.map((txn) => [
        txn["title"].toString(),
        "Rs ${txn["amount"].toStringAsFixed(2)}",
        txn["date"].toString().split(' ')[0],
      ]).toList(),
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
      final logoData = await rootBundle.load('assets/images/logo.png');
      return pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (e) {
      print('Error loading logo: $e');
      return null;
    }
  }
}
