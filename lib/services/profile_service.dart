import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_interceptor.dart';

class ProfileService {
  static const String baseUrl = 'http://10.0.2.2:8000';
  // static const String baseUrl = 'http://192.168.1.70:8000';


  static Future<Map<String, dynamic>> getProfile() async {
    return await AuthInterceptor.authorizedRequest(() async {
      final headers = {
        'Authorization': 'Bearer ${await AuthInterceptor.getValidAccessToken()}',
        'Content-Type': 'application/json',
      };
      final response = await http.get(
        Uri.parse('$baseUrl/profile/'),
        headers: headers,
      );
      return response;
    }).then((response) {
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load profile. Status: ${response.statusCode}');
      }
    });
  }

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    return await AuthInterceptor.authorizedRequest(() async {
      final headers = {
        'Authorization': 'Bearer ${await AuthInterceptor.getValidAccessToken()}',
        'Content-Type': 'application/json',
      };
      return await http.patch(
        Uri.parse('$baseUrl/profile/'),
        headers: headers,
        body: json.encode(data),
      );
    }).then((response) {
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update profile. Status: ${response.statusCode}');
      }
    });
  }

  static Future<Map<String, dynamic>> updateProfileImage(File image) async {
    return await AuthInterceptor.authorizedRequest(() async {
      final uri = Uri.parse('$baseUrl/profile/');
      final request = http.MultipartRequest('PATCH', uri);
      request.headers['Authorization'] = 'Bearer ${await AuthInterceptor.getValidAccessToken()}';
      request.files.add(await http.MultipartFile.fromPath('profile_image', image.path));

      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      return http.Response(respStr, response.statusCode);
    }).then((response) {
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update profile image. Status: ${response.statusCode}');
      }
    });
  }
}