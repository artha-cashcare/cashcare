import 'dart:io';
import 'package:cashcare/constant/api_constant.dart';
import 'package:cashcare/services/auth_interceptor.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ReceiptService {
  static final baseUrl = ApiConstants.baseUrl;

  Future<bool> uploadReceipt({
    required File receiptImage,
    required String amount,
    required String category,
    required String date,
  }) async {
    try {
      if (receiptImage.path.isEmpty || amount.isEmpty || category.isEmpty || date.isEmpty) {
        throw Exception('All fields are required');
      }

      final amountValue = double.tryParse(amount);
      if (amountValue == null) {
        throw Exception('Invalid amount format');
      }

      final response = await AuthInterceptor.authorizedRequest((token) async {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/api/scan_receipt/'),
        );

        request.headers['Authorization'] = 'Bearer $token';
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

        return await http.Response.fromStream(await request.send());
      });

      if (response.statusCode == 201) {
        Fluttertoast.showToast(msg: '📸 Receipt uploaded successfully!');
        return true;
      } else {
        Fluttertoast.showToast(
          msg: ' Error uploading: ${response.statusCode} - ${response.body}',
          toastLength: Toast.LENGTH_LONG,
        );
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: ' Failed to upload: ${e.toString()}',
        toastLength: Toast.LENGTH_LONG,
      );
      return false;
    }
  }
}
