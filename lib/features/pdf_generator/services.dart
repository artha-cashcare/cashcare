import 'dart:convert';
import 'package:cashcare/utils/token_helper.dart';
import 'package:http/http.dart' as http;
final headers =  TokenService.getAuthToken();

class ApiService {
  static Future<Map<String, dynamic>?> fetchMonthlySummary(String month) async {
    final url = Uri.parse("http://192.168.1.68:8000/monthly-summary/?month=$month");

    final response = await http.get(url, headers: await headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Error fetching summary: ${response.statusCode}");
      return null;
    }
  }
}
