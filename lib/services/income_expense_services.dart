import 'dart:convert';
import 'package:cashcare/services/auth_interceptor.dart';
import 'package:http/http.dart' as http;

class ApiService {

  Future<double> getTotalIncome() async {
    final accessToken = await AuthInterceptor.getValidAccessToken();

    if (accessToken == null) {
      throw Exception('No valid access token found');
    }

    final response = await AuthInterceptor.authorizedRequest(() {
      return http.get(
        Uri.parse('${AuthInterceptor.baseUrl}/income/'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
    });

    final List<dynamic> data = json.decode(response.body);

    double totalIncome = 0.0;
    for (var item in data) {
      totalIncome += double.tryParse(item['amount'].toString()) ?? 0.0;
    }
    return totalIncome;

  }

  Future<double> getTotalExpense() async {
    final accessToken = await AuthInterceptor.getValidAccessToken();

    if (accessToken == null) {
      throw Exception('No valid access token found');
    }

    final response = await AuthInterceptor.authorizedRequest(() {
      return http.get(
        Uri.parse('${AuthInterceptor.baseUrl}/expense/'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
    });

    final List<dynamic> data = json.decode(response.body);

    double totalExpense = 0.0;
    for (var item in data) {
      totalExpense += double.tryParse(item['amount'].toString()) ?? 0.0;
    }
    return totalExpense;

  }


  static const String baseUrl = 'http://10.0.2.2:8000';
  // static const String baseUrl = 'http://192.168.1.70:8000';

  Future<void> storeIncome(double amount, String source) async {
    final accessToken = await AuthInterceptor.getValidAccessToken();

    final url = Uri.parse('$baseUrl/income/');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'amount': amount,
          'category': source,
        }),
      );

      if (response.statusCode == 201) {
        print('Income added successfully');
      } else {
        throw Exception('Failed to add income: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to add income');
    }
  }

  Future<void> storeExpense(double amount, String category) async {
    final accessToken = await AuthInterceptor.getValidAccessToken();

    final url = Uri.parse('$baseUrl/expense/');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'amount': amount,
          'category': category,
        }),
      );

      if (response.statusCode == 201) {
        print('Income added successfully');
      } else {
        throw Exception('Failed to add income: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to add income');
    }
  }
}
