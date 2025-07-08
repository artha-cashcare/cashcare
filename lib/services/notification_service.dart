import 'dart:convert';
import 'package:cashcare/models/goal_notification.dart';
import 'package:cashcare/services/auth_interceptor.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  final String baseUrl = 'http://13.60.63.203:8000';

  Future<String> _getAuthToken() async {
    final token = await AuthInterceptor.getValidAccessToken();
    print("🔥 Access Token: $token");

    if (token == null || token.isEmpty) {
      throw Exception('Access token is missing or expired. Please log in again.');
    }
    return token;
  }


  Future<List<GoalNotification>> getNotifications() async {
    try {
      final token = await _getAuthToken();
      final response = await http.get(
        Uri.parse('$baseUrl/goal-notifications/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => GoalNotification.fromJson(item)).toList();
      } else {
        print('Response (${response.statusCode}): ${response.body}');
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading notifications: $e');
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final token = await _getAuthToken();
      final response = await http.patch(
        Uri.parse('$baseUrl/goal-notifications/mark_all_read/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        print('Failed markAllAsRead (${response.statusCode}): ${response.body}');
        throw Exception('Failed to mark notifications as read');
      }
    } catch (e) {
      print('Error marking as read: $e');
      rethrow;
    }
  }
}
