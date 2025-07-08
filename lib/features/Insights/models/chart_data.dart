class ChartData {
  final String category;
  final double amount;

  ChartData(this.category, this.amount);
}

class ChartResponse {
  final String? incomeChart;
  final String? expenseChart;
  final List<ChartData> incomeData;
  final List<ChartData> expenseData;

  ChartResponse({
    this.incomeChart,
    this.expenseChart,
    required this.incomeData,
    required this.expenseData, required charts,
  });
}