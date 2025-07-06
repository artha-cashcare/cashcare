import 'package:cashcare/services/stats_services.dart';
import 'package:cashcare/widgets/barchart_widget.dart';
import 'package:flutter/material.dart';
import 'monthly_detail_screen.dart';
class StatsScreen extends StatefulWidget {
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final statsService = StatsService();
  late Future<void> _fetchFuture;
  bool _showIncome = true;

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
    final monthly = await statsService.fetchMonthlyStats();
    final category = await statsService.fetchCategoryStats();

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
      appBar: AppBar(
        title: Text('Income & Expense Stats'),
        actions: [
          IconButton(
            icon: Icon(Icons.compare),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MonthlyComparisonScreen(
                    monthlyIncome: monthlyIncome,
                    monthlyExpense: monthlyExpense,
                  ),
                ),
              );
            },
          ),
        ],
      ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "📅 Monthly Overview",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ToggleButtons(
                      isSelected: [_showIncome, !_showIncome],
                      onPressed: (index) {
                        setState(() {
                          _showIncome = index == 0;
                        });
                      },
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text("Income", style: TextStyle(color: Colors.green)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text("Expense", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: _showIncome
                      ? buildSingleBarChart(monthlyIncome, Colors.green)
                      : buildSingleBarChart(monthlyExpense, Colors.red),
                ),
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