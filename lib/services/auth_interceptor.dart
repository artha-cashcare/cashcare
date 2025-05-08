import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String baseUrl = 'http://10.0.2.2:8000';
  // static const String baseUrl = 'http://192.168.1.70:8000';


  static Future<String?> getValidAccessToken() async {
    String? accessToken = await _storage.read(key: 'access_token');
    String? refreshToken = await _storage.read(key: 'refresh_token');

    if (accessToken == null || refreshToken == null) return null;

    print(accessToken);
    if (_isTokenExpired(accessToken)) {
      try {
        //if token expire
        final newToken = await _refreshAccessToken(refreshToken);
        if (newToken != null) {
          return newToken;
        } else {
          await logout();
          return null;
        }
      } catch (e) {
        await logout();
        return null;
      }
    }
    //like else statement
    return accessToken;
  }

  //yo chahi helper function apun ke lie
  static bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      final exp = payload['exp'];
      final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return currentTime >= exp;
    } catch (_) {
      return true;//if fails or expired token
    }
  }

  static Future<String?> _refreshAccessToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/refresh/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refreshToken}),
    );

    if (response.statusCode == 200) {
      final newData = jsonDecode(response.body);
      await _storage.write(key: 'access_token', value: newData['access']);
      return newData['access'];
    }
    return null;
  }

  static Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');

  }

  static Future<http.Response> authorizedRequest(
      Future<http.Response> Function() requestFunction,
      ) async {
    final accessToken = await getValidAccessToken();
    if (accessToken == null) {
      throw Exception('Authentication required');
    }

    final response = await requestFunction();

    if (response.statusCode == 401) {
      final newAccessToken = await getValidAccessToken();
      if (newAccessToken == null) {
        throw Exception('Session expired');
      }
      return await requestFunction();
    }

    return response;
  }
}