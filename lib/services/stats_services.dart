import 'dart:convert';
import 'package:http/http.dart' as http;

class StatsService {
  final String baseUrl = 'http://127.0.0.1:8000/api/stats'; 

  Future<Map<String, dynamic>> fetchMonthlyStats(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/monthly/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load monthly stats');
    }
  }

  Future<Map<String, dynamic>> fetchCategoryStats(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/category/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load category stats');
    }
  }
}
