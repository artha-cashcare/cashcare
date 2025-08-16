import 'package:cashcare/services/auth_interceptor.dart';

class TokenService {
  static Future<Map<String,String>> getAuthToken() async {
    final token = await AuthInterceptor.getValidAccessToken();
    print("Access Token: $token");


    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }
}
