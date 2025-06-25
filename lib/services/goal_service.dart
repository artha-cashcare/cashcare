import 'dart:convert';
import 'package:cashcare/services/auth_interceptor.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/goal_model.dart';

class GoalService {
  final String baseUrl='http://10.0.2.2:8000';


  Future<List<Goal>> getGoals() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/goals/'),
        headers: await _buildHeaders(),
      );

      print('API Response: ${response.statusCode} - ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        // First decode the JSON
        final decoded = json.decode(response.body);

        // Check if the decoded result is a List
        if (decoded is List) {
          return decoded.map((item) {
            // Ensure each item is a Map
            if (item is Map<String, dynamic>) {
              return Goal.fromJson(item);
            } else {
              throw Exception('Invalid goal format: $item');
            }
          }).toList();
        } else {
          throw Exception('Expected List but got ${decoded.runtimeType}');
        }
      } else {
        throw Exception('Failed to load goals: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getGoals(): $e');
      rethrow;
    }
  }

  Future<Goal> createGoal({
    required String title,
    required double targetAmount,
    required DateTime deadline,
    required List<GoalRule> rules,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/goals/'),
      headers: await _buildHeaders(),
      body: json.encode({
        'title': title,
        'target_amount': targetAmount,
        'deadline': deadline.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
        'rules': rules.map((rule) => ({
          'income_category': rule.incomeCategory,
          'percentage': rule.percentage,
        })).toList(),
      }),
    );

    if (response.statusCode == 201) {
      return Goal.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create goal: ${response.statusCode}');
    }
  }
  Future<Map<String, String>> _buildHeaders() async {
    final token = await AuthInterceptor.getValidAccessToken(); // await it!
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Exception _handleError(http.Response response) {
    try {
      final body = json.decode(response.body);

      if (body is Map<String, dynamic>) {
        if (body.containsKey('detail')) {
          return Exception(body['detail']);
        } else {
          return Exception('Unknown error format: ${response.body}');
        }
      } else {
        return Exception('Unexpected JSON format: $body');
      }
    } catch (e) {
      // This will catch and log any decoding issues
      print('Error decoding response: ${response.body}');
      return Exception('Invalid error response: ${response.body}');
    }
  }


}