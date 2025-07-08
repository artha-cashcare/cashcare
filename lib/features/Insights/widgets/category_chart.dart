import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../models/chart_data.dart' show ChartData;

class CategoryChart extends StatelessWidget {
  final String title;
  final List<ChartData> data;
  final Color color;

  const CategoryChart({
    super.key,
    required this.title,
    required this.data,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:color
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              // height: 300,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  title: AxisTitle(text: 'Category'),
                  labelRotation: 0,
                  labelStyle: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold),
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: 'Amount'),
                  labelStyle: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold),

                ),
                series: <CartesianSeries>[
                  ColumnSeries<ChartData, String>(
                    dataSource: data,
                    xValueMapper: (ChartData data, _) => data.category,
                    yValueMapper: (ChartData data, _) => data.amount,
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                    width: 0.5,
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelAlignment: ChartDataLabelAlignment.middle,
                    ),
                    animationDuration: 2000,
                  ),

                ],
                tooltipBehavior: TooltipBehavior(enable: true),

              ),
            ),
          ],
        ),
      ),
    );
  }
}