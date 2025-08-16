import 'dart:async' show TimeoutException;
import 'dart:convert';
import 'package:cashcare/constant/api_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final _storage = const FlutterSecureStorage();
  static final baseUrl=ApiConstants.baseUrl;




  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        body: json.encode({'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        await _storeTokens(
          accessToken: responseData['access'],
          refreshToken: responseData['refresh'],
        );
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['detail'] ??
            (response.statusCode == 401
                ? 'Invalid email or password'
                : 'Invalid email or password');
        throw Exception(errorMessage);
      }
    } on http.ClientException {
      throw Exception('Network error. Please check your connection');
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        body: json.encode({
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          'phone': phoneNumber,
        }),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 201) {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['email']?[0] ??
            (response.statusCode == 400
                ? 'Email already registered'
                : 'Registration failed');
        throw Exception(errorMessage);
      }
    } on http.ClientException {
      throw Exception('Network error. Please check your connection');
    } on TimeoutException {
      throw Exception('Server is not responding. Please try again later.');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _storeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);

  }

  Future<void> refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) throw Exception('No refresh token available');

      final response = await http.post(
        Uri.parse('$baseUrl/refresh'),
        body: json.encode({'refresh': refreshToken}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        await _storage.write(key: 'access_token', value: responseData['access']);
      } else {
        await logout();
        throw Exception('Session expired. Please login again.');
      }
    } catch (e) {
      await logout();
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      await _storage.deleteAll();
    }
  }

  Future<Map<String, String>> getAuthHeaders() async {
    String? accessToken = await _storage.read(key: 'access_token');

    if (accessToken == null) return {};

    if (_isTokenExpired(accessToken)) {
      await refreshToken();
      accessToken = await _storage.read(key: 'access_token');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
  }

  Future<String?> getUsername() async {
    return await _storage.read(key: 'user_name');
  }

  bool _isTokenExpired(String token) {
    try {
      final payload = token.split('.')[1];
      final decodedPayload = utf8.decode(base64Url.decode(base64Url.normalize(payload)));
      final Map<String, dynamic> payloadMap = json.decode(decodedPayload);

      final exp = payloadMap['exp'];
      if (exp == null) return false;

      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expiryDate);
    } catch (e) {
      return true;
    }
  }

  static Future<String?> sendPasswordResetEmail(String email) async {
    final url = Uri.parse('$baseUrl/api/password_reset/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return null;
      } else {
        final data = jsonDecode(response.body);
        return data['error'] ?? 'Something went wrong. Try again.';
      }
    } catch (e) {
      return 'Network error: $e';
    }
  }
}
