import 'dart:io';
import 'package:cashcare/services/auth_interceptor.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ReceiptService {
  static const String _baseUrl = 'http://10.0.2.2:8000/api';
  final  authToken=AuthInterceptor.getValidAccessToken();

  Future<bool> uploadReceipt({
    required File receiptImage,
    required String amount,
    required String category,
    required String date,
  }) async {
    try {
      // Validate inputs
      if (receiptImage == null || amount.isEmpty || category.isEmpty || date.isEmpty) {
        throw Exception('All fields are required');
      }

      final authToken = await AuthInterceptor.getValidAccessToken(); // <-- FIXED HERE

      final amountValue = double.tryParse(amount);
      if (amountValue == null) {
        throw Exception('Invalid amount format');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/scan_receipt/'),
      );

      request.headers['Authorization'] = 'Bearer $authToken'; // Now a proper string
      request.files.add(await http.MultipartFile.fromPath(
        'file_path',
        receiptImage.path,
        contentType: MediaType('image', 'jpeg'),
      ));
      request.fields.addAll({
        'amount': amountValue.toStringAsFixed(2),
        'category': category,
        'date': date,
      });

      var response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        Fluttertoast.showToast(msg: 'Receipt uploaded successfully!');
        return true;
      } else {
        Fluttertoast.showToast(
          msg: 'Error uploading receipt: ${response.statusCode} - $responseData',
          toastLength: Toast.LENGTH_LONG,
        );
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to upload receipt: ${e.toString()}',
        toastLength: Toast.LENGTH_LONG,
      );
      return false;
    }
  }

}