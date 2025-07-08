import 'dart:convert';
import 'package:cashcare/services/auth_interceptor.dart';
import 'package:http/http.dart' as http;

class StatsService {
  final String baseUrl = 'http://13.60.63.203:8000/stats';

  Future<Map<String, dynamic>> fetchMonthlyStats() async {
    final token = await AuthInterceptor.getValidAccessToken();

    final response = await http.get(
      Uri.parse('$baseUrl/monthly/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load monthly stats: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> fetchCategoryStats() async {
    final token = await AuthInterceptor.getValidAccessToken();

    final response = await http.get(
      Uri.parse('$baseUrl/category/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load category stats: ${response.body}');
    }
  }
}
