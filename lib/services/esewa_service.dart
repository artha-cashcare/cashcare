import 'dart:convert';
import 'package:cashcare/constant/api_constant.dart';
import 'package:cashcare/services/auth_interceptor.dart';
import 'package:http/http.dart' as http;

class PaymentService {
  static final baseUrl = ApiConstants.baseUrl;

  static Future<void> sendPaymentToServer({
    required String productId,
    required String productName,
    required String amount,
    required String referenceId,
    required String status,
    required String date,
  }) async {
    final url = Uri.parse('$baseUrl/verify-payment/');

    final response = await AuthInterceptor.authorizedRequest((token) {
      return http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "productId": productId,
          "productName": productName,
          "totalAmount": amount,
          "transactionDetails": {
            "referenceId": referenceId,
            "status": status,
            "date": date,
          }
        }),
      );
    });

    if (response.statusCode == 201) {
      print("Payment stored and user verified!");
    } else {
      print("Server Error [${response.statusCode}]: ${response.body}");
      throw Exception("Payment server error");
    }
  }
}
