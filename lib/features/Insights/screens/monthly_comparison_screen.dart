import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

import '../models/monthly_data.dart';
import '../services/api_service.dart';
import '../widgets/monthly_comparison_chart.dart';
import '../widgets/rounded_button.dart';

class MonthlyComparisonScreen extends StatefulWidget {
  const MonthlyComparisonScreen({super.key});

  @override
  State<MonthlyComparisonScreen> createState() => _MonthlyComparisonScreenState();
}

class _MonthlyComparisonScreenState extends State<MonthlyComparisonScreen> {
  late ApiService apiService;
  List<MonthlyData> monthlyData = [];
  MonthlyComparison? comparison;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    const token = 'your-auth-token';
    apiService = ApiService();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final monthlyResponse = await apiService.getMonthlyData();
      final comparisonResponse = await apiService.getMonthlyComparison();

      setState(() {
        monthlyData = monthlyResponse;
        comparison = comparisonResponse;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(IconlyBold.arrowLeftCircle, color: Colors.teal),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Monthly Comparison',
          style: TextStyle(fontFamily: 'poppins', color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : (comparison == null)
          ? SizedBox(
        height: MediaQuery.of(context).size.height -
            kToolbarHeight -
            MediaQuery.of(context).padding.top,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Not enough data to compare expenses yet.\nPlease add expenses for at least two different months.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  shadowColor: Colors.tealAccent.withOpacity(0.5),
                ),
                icon: Icon(
                  IconlyBold.arrowLeftSquare,
                  size: 24,
                  color: Colors.white,
                ),
                label: const Text(
                  'Back to Dashboard',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              // Your existing card with comparison info
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Comparison data shown here...',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (monthlyData.isNotEmpty)
              MonthlyComparisonChart(data: monthlyData),
            const SizedBox(height: 20),
            IconButton(onPressed: (){}, icon: Icon(IconlyBold.arrowLeftSquare)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
