import 'dart:convert';
import 'package:cashcare/constant/api_constant.dart';
import 'package:cashcare/services/auth_interceptor.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static final baseUrl = ApiConstants.baseUrl;

  Future<double> getTotalIncome() async {
    final response = await AuthInterceptor.authorizedRequest((token) {
      return http.get(
        Uri.parse('$baseUrl/income/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      double totalIncome = 0.0;
      for (var item in data) {
        totalIncome += double.tryParse(item['amount'].toString()) ?? 0.0;
      }
      return totalIncome;
    } else {
      throw Exception('Failed to fetch income: ${response.statusCode}');
    }
  }

  Future<double> getTotalExpense() async {
    final response = await AuthInterceptor.authorizedRequest((token) {
      return http.get(
        Uri.parse('$baseUrl/expense/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      double totalExpense = 0.0;
      for (var item in data) {
        totalExpense += double.tryParse(item['amount'].toString()) ?? 0.0;
      }
      return totalExpense;
    } else {
      throw Exception('Failed to fetch expense: ${response.statusCode}');
    }
  }

  Future<void> storeIncome(double amount, String source) async {
    final response = await AuthInterceptor.authorizedRequest((token) {
      return http.post(
        Uri.parse('$baseUrl/income/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amount,
          'category': source,
        }),
      );
    });

    if (response.statusCode == 201) {
      print('Income added successfully');
    } else {
      throw Exception('Failed to add income: ${response.statusCode}');
    }
  }

  Future<void> storeExpense(double amount, String category) async {
    final response = await AuthInterceptor.authorizedRequest((token) {
      return http.post(
        Uri.parse('$baseUrl/expense/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amount,
          'category': category,
        }),
      );
    });

    if (response.statusCode == 201) {
      print('Expense added successfully');
    } else {
      throw Exception('Failed to add expense: ${response.statusCode}');
    }
  }
}
