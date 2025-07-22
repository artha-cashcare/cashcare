import 'dart:convert';
import 'package:cashcare/constant/api_constant.dart';
import 'package:cashcare/models/goal_notification.dart';
import 'package:cashcare/services/auth_interceptor.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static final baseUrl = ApiConstants.baseUrl;

  Future<List<GoalNotification>> getNotifications() async {
    try {
      final response = await AuthInterceptor.authorizedRequest((token) {
        return http.get(
          Uri.parse('$baseUrl/goal-notifications/'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
      });

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => GoalNotification.fromJson(item)).toList();
      } else {
        print(' Response (${response.statusCode}): ${response.body}');
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      print(' Error loading notifications: $e');
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await AuthInterceptor.authorizedRequest((token) {
        return http.patch(
          Uri.parse('$baseUrl/goal-notifications/mark_all_read/'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
      });

      if (response.statusCode != 200) {
        print(' Failed markAllAsRead (${response.statusCode}): ${response.body}');
        throw Exception('Failed to mark notifications as read');
      }
    } catch (e) {
      print(' Error marking notifications as read: $e');
      rethrow;
    }
  }
}
