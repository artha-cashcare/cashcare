import 'dart:io';

import 'package:cashcare/models/navbar_provider.dart';
import 'package:cashcare/providers/profile_provider.dart';
import 'package:cashcare/screens/bottom_navs.dart' show BottomNavbar;
import 'package:cashcare/services/auth_interceptor.dart';
import 'package:cashcare/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:cashcare/auth/login_screen.dart';
import 'package:cashcare/features/splash/splash_screen.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  final profileProvider = ProfileProvider();
  await profileProvider.fetchProfile();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: profileProvider),
        ChangeNotifierProvider(create: (_) => BottomNavProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final _storage = const FlutterSecureStorage();
  final AuthInterceptor _authInterceptor = AuthInterceptor();

  Future<bool> _checkAuthStatus() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      return refreshToken != null;
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
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'CashCare',
          theme: ThemeData(primarySwatch: Colors.blue),
          home: snapshot.data == true ? BottomNavbar() : SplashScreen(),
        );
      },
    );
  }
}