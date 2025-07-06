import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

Widget buildSingleBarChart(List<dynamic> data, Color color) {
  if (data.isEmpty) return Center(child: Text("No data available"));

  // Calculate max value with a buffer
  final maxValue = data.fold<double>(0, (max, item) {
    final value = item['total'].toDouble();
    return value > max ? value : max;
  }) * 1.2;

  return BarChart(
    BarChartData(
      maxY: maxValue < 1000 ? 1000 : maxValue, // Minimum scale of 1000
      barGroups: data.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: item['total'].toDouble(),
              color: color,
              width: 30,
              borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        );
      }).toList(),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, _) {
              try {
                final month = DateTime.parse(data[value.toInt()]['month']).month;
                const monthLabels = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
                return Text(monthLabels[month - 1], style: TextStyle(fontSize: 12));
              } catch (e) {
                return Text('', style: TextStyle(fontSize: 12));
              }
            },
            reservedSize: 24,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, _) {
              return Text(
                value.toInt().toString(),
                style: TextStyle(fontSize: 10),
              );
            },
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.grey[200]!,
          strokeWidth: 1,
        ),
      ),
      borderData: FlBorderData(show: false),
    ),
  );
}

Widget buildCategoryChart(List<dynamic> data, Color color) {
  if (data.isEmpty) return Center(child: Text("No data available"));

  // Calculate max value with a buffer
  final maxValue = data.fold<double>(0, (max, item) {
    final value = item['total'].toDouble();
    return value > max ? value : max;
  }) * 1.2;

  return BarChart(
    BarChartData(
      maxY: maxValue < 1000 ? 1000 : maxValue, // Minimum scale of 1000
      barGroups: data.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: item['total'].toDouble(),
              color: color,
              width: 30,
              borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        );
      }).toList(),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, _) {
              final name = data[value.toInt()]['category__category_name'] ?? 'N/A';
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  name.length > 8 ? '${name.substring(0, 7)}…' : name,
                  style: TextStyle(fontSize: 10),
                ),
              );
            },
            reservedSize: 36,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, _) {
              return Text(
                value.toInt().toString(),
                style: TextStyle(fontSize: 10),
              );
            },
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.grey[200]!,
          strokeWidth: 1,
        ),
      ),
      borderData: FlBorderData(show: false),
    ),
  );
}