import 'package:cashcare/services/stats_services.dart';
import 'package:cashcare/widgets/barchart_widget.dart';
import 'package:flutter/material.dart';


class StatsScreen extends StatefulWidget {
  final String token;
  const StatsScreen({required this.token});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final statsService = StatsService();
  late Future<void> _fetchFuture;

  List<dynamic> monthlyIncome = [];
  List<dynamic> monthlyExpense = [];
  List<dynamic> categoryIncome = [];
  List<dynamic> categoryExpense = [];

  @override
  void initState() {
    super.initState();
    _fetchFuture = _fetchStats();
  }

  Future<void> _fetchStats() async {
    final monthly = await statsService.fetchMonthlyStats(widget.token);
    final category = await statsService.fetchCategoryStats(widget.token);

    setState(() {
      monthlyIncome = monthly['income'];
      monthlyExpense = monthly['expense'];
      categoryIncome = category['income_by_category'];
      categoryExpense = category['expense_by_category'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Income & Expense Stats')),
      body: FutureBuilder(
        future: _fetchFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text("📅 Monthly Comparison", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 300, child: buildMonthlyChart(monthlyIncome, monthlyExpense)),
                SizedBox(height: 32),

                Text("📊 Income by Category", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 300, child: buildCategoryChart(categoryIncome, Colors.green)),
                SizedBox(height: 32),

                Text("📉 Expense by Category", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 300, child: buildCategoryChart(categoryExpense, Colors.red)),
              ],
            ),
          );
        },
      ),
    );
  }
}
