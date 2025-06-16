import 'dart:convert';

import 'package:cashcare/models/history.dart';
import 'package:cashcare/services/auth_interceptor.dart';
import 'package:http/http.dart' as http;
class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  Future<List<TransactionModel>> getAllTransactions() async {
    final token = await AuthInterceptor.getValidAccessToken();
    if (token == null) throw Exception('Token missing');

    final response = await http.get(
      Uri.parse('$baseUrl/history/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => TransactionModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load transactions');
    }
  }
}