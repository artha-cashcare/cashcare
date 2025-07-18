import 'dart:convert';
import 'package:cashcare/utils/token_helper.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:esewa_flutter_sdk/esewa_config.dart';
import 'package:esewa_flutter_sdk/esewa_flutter_sdk.dart';
import 'package:esewa_flutter_sdk/esewa_payment.dart';
import 'package:esewa_flutter_sdk/esewa_payment_success_result.dart' show EsewaPaymentSuccessResult;
import 'package:provider/provider.dart';

const String CLIENT_ID = 'JB0BBQ4aD0UqIThFJwAKBgAXEUkEGQUBBAwdOgABHD4DChwUAB0R';
const String SECRET_KEY = 'BhwIWQQADhIYSxILExMcAgFXFhcOBwAKBgAXEQ==';

class Esewa {
  late final BuildContext context;
  final headers =  TokenService.getAuthToken();


  void startEsewaPayment() {
    try {
      EsewaFlutterSdk.initPayment(
        esewaConfig: EsewaConfig(
          environment: Environment.test,
          clientId: CLIENT_ID,
          secretId: SECRET_KEY,
        ),
        esewaPayment: EsewaPayment(
          productId: "1234567890",
          productName: "Test Product",
          productPrice: "10",
          callbackUrl: '',
        ),
        onPaymentSuccess: (EsewaPaymentSuccessResult result) async {
          print("✅ Payment Success: $result");

          // Call Django API to verify user
          await verifyUserAsPremium();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("🎉 Payment success! Premium activated.")),
          );
        },
        onPaymentFailure: (error) {
          print("❌ Payment Failed: $error");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ Payment failed.")),
          );
        },
        onPaymentCancellation: (cancel) {
          print("🚫 Payment Cancelled: $cancel");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("🚫 Payment cancelled.")),
          );
        },
      );
    } catch (e) {
      print("Exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❗ Error starting payment: $e")),
      );
    }
  }

  Future<void> verifyUserAsPremium() async {
    final url = Uri.parse('http://10.0.2.2:8000/api/verify-payment/'); // ✅ Correct URL for local Django server
    final response = await http.post(
      url,
      headers: await headers
    );

    if (response.statusCode == 200) {
      print("✅ User verified as premium.");
    } else {
      print("❌ Failed to verify user. ${response.body}");
    }
  }
}
