import 'dart:convert';
import 'package:cashcare/services/auth_interceptor.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/goal_model.dart';

class GoalService {
  final String baseUrl='http://13.60.63.203:8000';


  Future<List<Goal>> getGoals() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/goals/'),
        headers: await _buildHeaders(),
      );

      print('API Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded is List) {
          return decoded.map((item) {
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
        'deadline': deadline.toIso8601String().split('T')[0],
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
    final token = await AuthInterceptor.getValidAccessToken();
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
      print('Error decoding response: ${response.body}');
      return Exception('Invalid error response: ${response.body}');
    }
  }


}