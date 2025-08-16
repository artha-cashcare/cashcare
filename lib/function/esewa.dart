  import 'package:cashcare/services/esewa_service.dart';
import 'package:esewa_flutter_sdk/esewa_flutter_sdk.dart';
  import 'package:esewa_flutter_sdk/esewa_config.dart';
  import 'package:esewa_flutter_sdk/esewa_payment.dart';
  import 'package:esewa_flutter_sdk/esewa_payment_success_result.dart';
  import 'package:flutter/material.dart';

  class Esewa {
    Future<void> pay(BuildContext context) async {
      try {
        EsewaFlutterSdk.initPayment(
          esewaConfig: EsewaConfig(
            environment: Environment.test,
            clientId: "JB0BBQ4aD0UqIThFJwAKBgAXEUkEGQUBBAwdOgABHD4DChwUAB0R",
            secretId: "BhwIWQQADhIYSxILExMcAgFXFhcOBwAKBgAXEQ=="

          ),
          esewaPayment: EsewaPayment(
            productId: "1d71jd81",
            productName: "Premium 1",
            productPrice: "2000",
            callbackUrl: 'https://yourdomain.com/callback',
          ),
          onPaymentSuccess: (EsewaPaymentSuccessResult result) async{
            debugPrint('Payment SUCCESS: ${result.productName}, ${result.totalAmount}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Payment Successful!')),
            );


            try {
              await PaymentService.sendPaymentToServer(
                productId: "1d71jd81",
                productName: result.productName,
                amount: result.totalAmount,
                referenceId: result.refId,
                status: "Success",
                date: DateTime.now().toIso8601String(),
              );
            } catch (e) {
              debugPrint("Failed to send payment to server: $e");
            }

          },


          onPaymentFailure: () {
            debugPrint('Payment FAILURE');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Payment Failed!')),
            );
          },
          onPaymentCancellation: () {
            debugPrint('Payment CANCELLED');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Payment Cancelled by User')),
            );
          },
        );
      } catch (e) {
        debugPrint('Payment EXCEPTION: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during payment: $e')),
        );
      }
    }
  }
