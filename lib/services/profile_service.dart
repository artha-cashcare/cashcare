import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cashcare/constant/api_constant.dart';
import 'auth_interceptor.dart';

class ProfileService {
  static final baseUrl = ApiConstants.baseUrl;

  static Future<Map<String, dynamic>> getProfile() async {
    return await AuthInterceptor.authorizedRequest((token) async {
      final response = await http.get(
        Uri.parse('$baseUrl/profile/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
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
    return await AuthInterceptor.authorizedRequest((token) async {
      final response = await http.patch(
        Uri.parse('$baseUrl/profile/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );
      return response;
    }).then((response) {
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update profile. Status: ${response.statusCode}');
      }
    });
  }

  static Future<Map<String, dynamic>> updateProfileImage(File image) async {
    return await AuthInterceptor.authorizedRequest((token) async {
      final uri = Uri.parse('$baseUrl/profile/');
      final request = http.MultipartRequest('PATCH', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('profile_image', image.path));

      final streamedResponse = await request.send();
      final respStr = await streamedResponse.stream.bytesToString();

      return http.Response(respStr, streamedResponse.statusCode);
    }).then((response) {
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update profile image. Status: ${response.statusCode}');
      }
    });
  }
}
