import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cashcare/screens/home_screen.dart';
import 'package:cashcare/auth/login_screen.dart';
import 'package:cashcare/features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _storage = const FlutterSecureStorage();

  MyApp({super.key});

  Future<bool> _checkAuthStatus() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) return false;

      // Optional: Add JWT expiration check here
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkAuthStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'CashCare',
          theme: ThemeData(primarySwatch: Colors.blue),
          home: snapshot.data == true ? HomeScreen() : SplashScreen(),
        );
      },
    );
  }
}