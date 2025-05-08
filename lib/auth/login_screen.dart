import 'dart:async';
import 'dart:io';

import 'package:cashcare/auth/forgot_password.dart';
import 'package:cashcare/auth/signup_screen.dart';
import 'package:cashcare/screens/bottom_navs.dart';
import 'package:cashcare/screens/home_screen.dart';
import 'package:cashcare/services/auth_service.dart';
import 'package:cashcare/utils/snackbar_service.dart' show SnackBarService;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Submit Function
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Check internet connection
      if (!await _hasInternetConnection()) {
        if (!mounted) return;
        SnackBarService.showCustomSnackBar(
          context: context,
          message: 'No internet connection',
          icon: const Icon(Icons.wifi_off, color: Colors.white, size: 24),
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }

      // Attempt login with timeout
      await _authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      // Success
      SnackBarService.showCustomSnackBar(
        context: context,
        message: 'Login successful!',
        icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 24),
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BottomNavbar()),
      );
    } on TimeoutException {
      if (!mounted) return;
      SnackBarService.showCustomSnackBar(
        context: context,
        message: 'Server is not responding. Please try again later.',
        icon: const Icon(Icons.timer_off, color: Colors.white, size: 24),
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } catch (e) {
      if (!mounted) return;

      String errorMessage = 'Login failed';
      if (e.toString().contains('Invalid email or password')) {
        errorMessage = 'Invalid email or password';
      } else if (e.toString().contains('Network error')) {
        errorMessage = 'Network error. Please check your connection';
      }

      SnackBarService.showCustomSnackBar(
        context: context,
        message: errorMessage,
        icon: const Icon(Icons.error_outline, color: Colors.white, size: 24),
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Image.asset('assets/images/logo.png', height: 150),

              const SizedBox(height: 20),
              const Text(
                'Welcome Back!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Login to your account',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Container(
                height: 70,
                width: 70,
                color: Colors.grey[100],
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/google_logo.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Divider(color: Colors.black, thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'OR Sign in with',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.black, thickness: 1)),
                ],
              ),

              SizedBox(height: 15),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        labelText: 'Email or Phone',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email or phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      obscureText: _obscurePassword,
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[200],
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot  Password?',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),

              Container(
                width: double.infinity,
                child: ElevatedButton(
                  // onPressed: () {
                  //   Navigator.pushReplacement(
                  //     context,
                  //     MaterialPageRoute(builder: (context) => BottomNavbar()),
                  //   );
                  // },

                  onPressed: _isLoading ? null : _submit, // Only call _submit if not loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                    minimumSize: Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child:
                      _isLoading
                          ? CupertinoActivityIndicator() // Show progress indicator while loading
                          : Text(
                            'Sign In',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),

              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (builder) => SignupPage()),
                      );
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
