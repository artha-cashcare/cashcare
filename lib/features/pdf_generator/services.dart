  import 'dart:convert';
  import 'package:cashcare/constant/api_constant.dart';
  import 'package:cashcare/utils/token_helper.dart';
  import 'package:http/http.dart' as http;

  class ApiService {
    static final baseUrl = ApiConstants.baseUrl;

    static Future<Map<String, dynamic>?> fetchSummary(Map<String, String> queryParams) async {
      final token = await TokenService.getAuthToken();

      final uri = Uri.parse("$baseUrl/monthly-summary/").replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: token);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Error fetching summary: ${response.statusCode}");
        print("Response body: ${response.body}");
        return null;
      }
    }
  }
