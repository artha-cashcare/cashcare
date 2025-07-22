import 'dart:convert';
import 'package:cashcare/constant/api_constant.dart';
import 'package:cashcare/services/auth_interceptor.dart';
import 'package:http/http.dart' as http;

class StatsService {
  static final baseUrl = ApiConstants.baseUrl;

  Future<Map<String, dynamic>> fetchMonthlyStats() async {
    final response = await AuthInterceptor.authorizedRequest((token) async {
      return await http.get(
        Uri.parse('$baseUrl/stats/monthly/'),
        headers: {'Authorization': 'Bearer $token'},
      );
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load monthly stats: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> fetchCategoryStats() async {
    final response = await AuthInterceptor.authorizedRequest((token) async {
      return await http.get(
        Uri.parse('$baseUrl/stats/category/'),
        headers: {'Authorization': 'Bearer $token'},
      );
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load category stats: ${response.body}');
    }
  }
}
