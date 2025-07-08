import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

import '../models/chart_data.dart' show ChartResponse;
import '../models/recommendation.dart' show Recommendation;
import '../services/api_service.dart' show ApiService;
import '../widgets/category_chart.dart';
import '../widgets/recommendation_card.dart';
import '../widgets/rounded_button.dart' show RoundedButton;
import 'monthly_comparison_screen.dart';


class InsighScreen extends StatefulWidget {

  @override
  State<InsighScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<InsighScreen> {
  late ApiService apiService;
  ChartResponse? chartData;
  Recommendation? recommendation;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Replace with your actual token
    const token = 'your-auth-token';
    apiService = ApiService();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final chartResponse = await apiService.getCategoryCharts();
      final recommendationData = await apiService.getRecommendation();

      setState(() {
        chartData = chartResponse;
        recommendation = recommendationData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load data: $e';print(errorMessage);
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
          'Insights',
          style: TextStyle(fontFamily: 'poppins', color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (recommendation != null)
              RecommendationCard(recommendation: recommendation!),
            const SizedBox(height: 20),
            if (chartData != null && chartData!.incomeData.isNotEmpty)
              CategoryChart(
                title: 'Income by Category',
                data: chartData!.incomeData,
                color: Colors.green,
              ),
            const SizedBox(height: 20),
            if (chartData != null && chartData!.expenseData.isNotEmpty)
              CategoryChart(
                title: 'Expenses by Category',
                data: chartData!.expenseData,
                color: Colors.red,
              ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MonthlyComparisonScreen(),
                  ),
                );
              }
              ,
              child:  Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'View Monthly Comparison',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}