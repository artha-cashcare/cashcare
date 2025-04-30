import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final _storage = const FlutterSecureStorage();
  final String baseUrl = 'http://10.0.2.2:8000/api/auth';

  // Improved register method
// Change the return type to Future<http.Response>
  // Enhanced login with better error handling
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        body: json.encode({'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        await _storeTokens(
          accessToken: responseData['access'],
          refreshToken: responseData['refresh'],
          userName: responseData['user']?['first_name'],
        );
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['detail'] ??
            (response.statusCode == 401
                ? 'Invalid email or password'
                : 'Login failed');
        throw Exception(errorMessage);
      }
    } on http.ClientException {
      throw Exception('Network error. Please check your connection');
    } catch (e) {
      rethrow;
    }
  }

// Improved register method with better error handling
  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        body: json.encode({
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phoneNumber,
        }),
        headers: {'Content-Type': 'application/json'},
      );

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
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _storeTokens({
    required String accessToken,
    required String refreshToken,
    String? userName,
  }) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
    if (userName != null) {
      await _storage.write(key: 'user_name', value: userName);
    }
  }

  // Token refresh logic
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

  // Secure logout
  Future<void> logout() async {
    try {
      // Optional: Call your backend logout endpoint if needed
      await _storage.deleteAll();
    } catch (e) {
      // Even if logout fails, clear local storage
      await _storage.deleteAll();
    }
  }

  // Get auth headers with auto-refresh
  Future<Map<String, String>> getAuthHeaders() async {
    String? accessToken = await _storage.read(key: 'access_token');

    // If no token, return empty headers
    if (accessToken == null) return {};

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
  }

  Future<String?> getUsername() async {
    return await _storage.read(key: 'user_name');
  }
}