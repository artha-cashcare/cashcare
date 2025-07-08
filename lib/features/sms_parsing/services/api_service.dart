import 'dart:convert';
import 'package:cashcare/features/sms_parsing/models/smsparse_model.dart';
import 'package:http/http.dart' as http;
import 'package:cashcare/services/auth_interceptor.dart';

class ApiService {
  static const String baseUrl = 'http://13.60.63.203:8000';


  Future<String> _getAuthToken() async {
    final token = await AuthInterceptor.getValidAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Access token is missing or expired. Please log in again.');
    }
    return token;
  }

  Future<List<SmsTransaction>> fetchParsedSms() async {
    final token = await _getAuthToken();
    final response = await http.get(
      Uri.parse('$baseUrl/parsed-sms/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => SmsTransaction.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  Future<bool> postTransaction(SmsTransaction transaction) async {
    final token = await _getAuthToken();
    final response = await http.post(
      Uri.parse('$baseUrl/parsed-sms/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(transaction.toJson()),
    );
    return response.statusCode == 201;
  }
}