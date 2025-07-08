class MonthlyData {
  final DateTime month;
  final double income;
  final double expense;

  MonthlyData(this.month, this.income, this.expense);
}

class MonthlyComparison {
  final String currentMonth;
  final String lastMonth;
  final double currentExpense;
  final double lastExpense;
  final double expenseChange;
  final String message;

  MonthlyComparison({
    required this.currentMonth,
    required this.lastMonth,
    required this.currentExpense,
    required this.lastExpense,
    required this.expenseChange,
    required this.message,
  });
}