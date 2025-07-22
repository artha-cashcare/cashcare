import 'dart:convert';
import 'package:cashcare/constant/api_constant.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class GoogleAuthService {
  // FlutterSecureStorage instance
  static final _secureStorage = const FlutterSecureStorage();
  static final baseUrl=ApiConstants.baseUrl;

  // Google Sign-In config
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    serverClientId: '883174720862-sat6t1umo7e8q6c9nan8lgih4t28d8pc.apps.googleusercontent.com',
  );

  static Future<bool> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut(); // optional: always pick account
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) throw Exception('Google ID token is null');

      print("ID Token: $idToken");

      // Send to your Django backend

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/google/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_token': idToken}),
      );

      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        await _secureStorage.write(key: 'access_token', value: responseData['access']);
        await _secureStorage.write(key: 'refresh_token', value: responseData['refresh']);

        return true;
      } else {
        throw Exception('Backend error: ${response.body}');
      }
    } catch (e) {
      print("Google Sign-In Error: $e");
      throw Exception('Google sign-in error: $e');
    }
  }

  // Optional: Helper to fetch token
  static Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: 'access_token');
  }

  static Future<void> logout() async {
    await _googleSignIn.signOut();
    await _secureStorage.deleteAll(); // clear tokens
  }
}
