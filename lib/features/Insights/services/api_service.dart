import 'dart:convert';
import 'package:cashcare/constant/api_constant.dart';
import 'package:cashcare/services/auth_interceptor.dart';
import 'package:http/http.dart' as http;

import '../models/chart_data.dart' show ChartResponse, ChartData;
import '../models/monthly_data.dart';
import '../models/recommendation.dart';
import 'package:cashcare/utils/token_helper.dart';
class ApiService {
  static final baseUrl=ApiConstants.baseUrl;

  final headers =  TokenService.getAuthToken();

  Future<ChartResponse> getCategoryCharts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user-chart-data/'),
        headers: await headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<ChartData> incomeData = [];
        if (data['income'] != null) {
          incomeData = (data['income'] as List).map((item) {
            final category = item['category']?.toString() ?? 'Unknown';
            final total = (item['total'] as num).toDouble();
            return ChartData(category, total);
          }).toList();
        }

        List<ChartData> expenseData = [];
        if (data['expense'] != null) {
          expenseData = (data['expense'] as List).map((item) {
            final category = item['category']?.toString() ?? 'Unknown';
            final total = (item['total'] as num).toDouble();
            return ChartData(category, total);
          }).toList();
        }

        return ChartResponse(
          incomeData: incomeData,
          expenseData: expenseData,
          charts: data['charts'] ?? {},
        );
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }

  Future<List<MonthlyData>> getMonthlyData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/monthly-income-chart/'),
       headers: await headers
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        final incomeMap = <DateTime, double>{};
        if (data['income'] != null) {
          for (var item in data['income'] as List) {
            incomeMap[DateTime.parse(item['month'] as String)] =
                (item['total_income'] as num).toDouble();
          }
        }

        final expenseMap = <DateTime, double>{};
        if (data['expense'] != null) {
          for (var item in data['expense'] as List) {
            expenseMap[DateTime.parse(item['month'] as String)] =
                (item['total_expense'] as num).toDouble();
          }
        }

        final allMonths = {...incomeMap.keys, ...expenseMap.keys}.toList();
        allMonths.sort((a, b) => a.compareTo(b));

        return allMonths.map((month) => MonthlyData(
          month,
          incomeMap[month] ?? 0,
          expenseMap[month] ?? 0,
        )).toList();
      } else {
        throw Exception('Failed to load monthly dassta: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getMonthlyData: $e');
      throw Exception('Failed to load monthly data: $e');
    }
  }

  Future<MonthlyComparison?> getMonthlyComparison() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/expense_comparison/'),
        headers: await headers
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        if (data.containsKey('current_month') &&
            data.containsKey('last_month') &&
            data.containsKey('current_expense') &&
            data.containsKey('last_expense') &&
            data.containsKey('expense_change') &&
            data.containsKey('message')) {

          return MonthlyComparison(
            currentMonth: data['current_month'].toString(),
            lastMonth: data['last_month'].toString(),
            currentExpense: (data['current_expense'] as num).toDouble(),
            lastExpense: (data['last_expense'] as num).toDouble(),
            expenseChange: (data['expense_change'] as num).toDouble(),
            message: data['message'] as String,
          );
        } else {
          print('Not enough data to compare expenses.');
          return null;
        }
      } else {
        throw Exception('Failed to load monthly comparison: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getMonthlyComparison: $e');
      throw Exception('Failed to load monthly comparison: $e');
    }
  }

  Future<Recommendation> getRecommendation() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/source-expense-comparison/'),
        headers: await headers,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;


        final highestSource = data['highest_source']?.toString() ?? 'Unknown Source';
        final highestExpense = (data['highest_expense'] as num?)?.toDouble() ?? 0.0;
        final message = data['message']?.toString() ?? 'No recommendations available';

        return Recommendation(
          highestSource: highestSource,
          highestExpense: highestExpense,
          message: message,
        );
      } else {
        throw Exception('Failed to load recommendation: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getRecommendation: $e');
      return Recommendation(
        highestSource: 'Unknown',
        highestExpense: 0.0,
        message: 'No recommendations available due to technical issues',
      );
    }
  }
}