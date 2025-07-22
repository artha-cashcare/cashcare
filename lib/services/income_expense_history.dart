import 'dart:convert';
import 'package:cashcare/constant/api_constant.dart';
import 'package:cashcare/models/history.dart';
import 'package:cashcare/services/auth_interceptor.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static final baseUrl = ApiConstants.baseUrl;

  Future<List<TransactionModel>> getAllTransactions() async {
    final response = await AuthInterceptor.authorizedRequest((token) {
      return http.get(
        Uri.parse('$baseUrl/history/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => TransactionModel.fromJson(item)).toList();
    } else {
      throw Exception(' Failed to load transactions: ${response.statusCode}');
    }
  }
}
