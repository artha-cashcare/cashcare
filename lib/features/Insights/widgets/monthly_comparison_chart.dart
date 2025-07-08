import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../models/monthly_data.dart' show MonthlyData;

class MonthlyComparisonChart extends StatelessWidget {
  final List<MonthlyData> data;

  const MonthlyComparisonChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Monthly Income vs Expenses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  labelRotation: -45,
                  labelStyle: const TextStyle(fontSize: 10),
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: 'Amount'),
                ),
                series: <CartesianSeries>[
                  ColumnSeries<MonthlyData, String>(
                    dataSource: data,
                    xValueMapper: (MonthlyData data, _) =>
                    '${data.month.month}/${data.month.year}',
                    yValueMapper: (MonthlyData data, _) => data.income,
                    name: 'Income',
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                    width: 0.4,
                  ),
                  ColumnSeries<MonthlyData, String>(
                    dataSource: data,
                    xValueMapper: (MonthlyData data, _) =>
                    '${data.month.month}/${data.month.year}',
                    yValueMapper: (MonthlyData data, _) => data.expense,
                    name: 'Expense',
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                    width: 0.4,
                  ),
                ],
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.top,
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}