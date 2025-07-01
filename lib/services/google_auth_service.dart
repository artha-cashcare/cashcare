import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static Future<bool> signInWithGoogle() async {
    try {
      // Initialize with your client IDs
      await _googleSignIn.initialize(
        clientId: '', // your iOS client id if any or empty
        serverClientId: '169167485751-b53dcjaa0bi7mugheioelt7sipboodbf.apps.googleusercontent.com',
      );

      // Sign out first (optional)
      await _googleSignIn.signOut();

      // Listen for authentication events (optional)
      _googleSignIn.authenticationEvents.listen((event) {
        // handle events like sign in/out here if you want
      });

      // Attempt lightweight authentication (optional)
      await _googleSignIn.attemptLightweightAuthentication();

      // Then start sign-in flow
      final GoogleSignInAccount? user = await _googleSignIn.authenticate();

      if (user == null) return false;

      final GoogleSignInAuthentication auth = await user.authentication;

      final idToken = auth.idToken;

      if (idToken == null) {
        throw Exception('Google ID token is null');
      }

      print("ID Token: $idToken");

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/auth/google/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_token': idToken}),
      );

      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");


      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Backend error: ${response.body}');
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
      throw Exception('Google sign-in error: $e');
    }
  }
}
