import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MonthlyComparisonScreen extends StatelessWidget {
  final List<dynamic> monthlyIncome;
  final List<dynamic> monthlyExpense;

  const MonthlyComparisonScreen({
    required this.monthlyIncome,
    required this.monthlyExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Monthly Comparison')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Income vs Last Month", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 300, child: _buildComparisonChart(monthlyIncome, Colors.green)),
            SizedBox(height: 32),
            Text("Expense vs Last Month", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 300, child: _buildComparisonChart(monthlyExpense, Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonChart(List<dynamic> data, Color color) {
    if (data.length < 2) {
      return Center(child: Text("Not enough data for comparison"));
    }

    final currentMonth = data[0];
    final lastMonth = data[1];
    final percentageChange = ((currentMonth['total'] - lastMonth['total']) / lastMonth['total']) * 100;

    return Column(
      children: [
        Text(
          "${percentageChange >= 0 ? '+' : ''}${percentageChange.toStringAsFixed(1)}%",
          style: TextStyle(
            fontSize: 18,
            color: percentageChange >= 0 ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Expanded(
          child: BarChart(
            BarChartData(
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: lastMonth['total'].toDouble(),
                      color: color.withOpacity(0.5),
                      width: 30,
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                      toY: currentMonth['total'].toDouble(),
                      color: color,
                      width: 30,
                    ),
                  ],
                ),
              ],
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      return Text(
                        value == 0 ? 'Last Month' : 'Current',
                        style: TextStyle(fontSize: 12),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                  ),
                ),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: false),
            ),
          ),
        ),
      ],
    );
  }
}