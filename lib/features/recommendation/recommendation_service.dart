import 'dart:convert';
import 'package:cashcare/constant/api_constant.dart';
import 'package:cashcare/services/auth_interceptor.dart';
import 'package:cashcare/utils/token_helper.dart';
import 'package:http/http.dart' as http;

class AISuggestionService {

  static final baseUrl=ApiConstants.baseUrl;
  Future<Map<String, String>> _buildHeaders() async {
    final token = await AuthInterceptor.getValidAccessToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }
  Future<Map<String, dynamic>> generateSuggestion() async {
    final header = await TokenService.getAuthToken();

    final url = Uri.parse('$baseUrl/suggestionAI/generate/');
    final response = await http.get(url, headers: header);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to generate suggestion');
    }
  }
}
