import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

Widget buildMonthlyChart(List<dynamic> incomeData, List<dynamic> expenseData) {
  final months = incomeData.map((e) => DateTime.parse(e['month']).month).toSet().toList()
    ..addAll(expenseData.map((e) => DateTime.parse(e['month']).month))
    ..sort();

  return BarChart(
    BarChartData(
      barGroups: months.map((month) {
        final income = incomeData.firstWhere(
              (i) => DateTime.parse(i['month']).month == month,
          orElse: () => {'total': 0},
        );
        final expense = expenseData.firstWhere(
              (e) => DateTime.parse(e['month']).month == month,
          orElse: () => {'total': 0},
        );

        return BarChartGroupData(
          x: month,
          barRods: [
            BarChartRodData(
              toY: double.tryParse(income['total'].toString()) ?? 0,
              color: Colors.green,
              width: 8,
            ),
            BarChartRodData(
              toY: double.tryParse(expense['total'].toString()) ?? 0,
              color: Colors.red,
              width: 8,
            ),
          ],
        );
      }).toList(),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, _) {
              final month = value.toInt();
              const monthLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
              return Text(monthLabels[month - 1], style: TextStyle(fontSize: 10));
            },
          ),
        ),
      ),
    ),
  );
}

Widget buildCategoryChart(List<dynamic> data, Color color) {
  return BarChart(
    BarChartData(
      barGroups: data.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: double.tryParse(item['total'].toString()) ?? 0,
              color: color,
              width: 14,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        );
      }).toList(),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final name = data[value.toInt()]['category__category_name'] ?? 'N/A';
              return RotatedBox(quarterTurns: 1, child: Text(name, style: TextStyle(fontSize: 10)));
            },
          ),
        ),
      ),
    ),
  );
}
