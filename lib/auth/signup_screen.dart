import 'dart:async';
import 'dart:io';

import 'package:cashcare/auth/login_screen.dart';
import 'package:cashcare/services/auth_service.dart';
import 'package:cashcare/utils/snackbar_service.dart' show SnackBarService;
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  bool _termsAccepted = false;
  bool _showTermsError = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final AuthService authService = AuthService();

  bool isLoading = false;
  void _submit() async {
    if (!_formKey.currentState!.validate() || !_termsAccepted) {
      setState(() => _showTermsError = !_termsAccepted);
      SnackBarService.showCustomSnackBar(context: context,message: 'Please complete all fields and accept the terms.',icon: Icon(IconlyBold.danger),backgroundColor: Colors.red,textColor: Colors.white);
      return;
    }

    setState(() {
      _showTermsError = false;
      isLoading = true;
    });

    try {
      if (!await checkInternetConnection()) {
        SnackBarService.showCustomSnackBar(context: context,message: 'No internet Connection.',icon: Icon(IconlyBold.danger),backgroundColor: Colors.red,textColor: Colors.white);
        return;
      }

      await authService.register(
        email: emailController.text,
        password: passwordController.text,
        firstName: nameController.text.split(" ")[0],
        lastName: nameController.text.split(" ").last,
        phoneNumber: phoneController.text,
      ).timeout(const Duration(seconds: 10));

      SnackBarService.showCustomSnackBar(context: context,message: 'Registration Successful.',icon: Icon(Icons.check_circle_outline),backgroundColor: Colors.green,textColor: Colors.white);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } on TimeoutException {
      SnackBarService.showCustomSnackBar(context: context,message: 'Server is not responding,please try again.',icon: Icon(IconlyBold.danger),backgroundColor: Colors.red,textColor: Colors.white);
    } catch (e) {
      final errorMessage = _parseErrorMessage(e);
      SnackBarService.showCustomSnackBar(context: context,message: errorMessage,icon: Icon(IconlyBold.danger),backgroundColor: Colors.red,textColor: Colors.white);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  String _parseErrorMessage(dynamic e) {
    if (e.toString().contains('custom user with this email already exists') ||
        e.toString().contains('Email already registered')) {
      return 'This email is already registered.';
    } else if (e.toString().contains('Network error')) {
      return 'Network error. Please check your internet connection.';
    }
    return e.toString().replaceFirst('Exception: ', '');
  }



// Helper function to check internet connectivity
  Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Image.asset('assets/images/logo.png', height: 130),
              const SizedBox(height: 10),
              const Text(
                "Welcome to CashCare",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Stay on top of your income and expenses.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {},
                icon: Image.asset('assets/images/google_logo.jpg', height: 24),
                label: const Text("Sign up with Google"),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: const [
                  Expanded(child: Divider(thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("or sign up with"),
                  ),
                  Expanded(child: Divider(thickness: 1)),
                ],
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Enter your name' : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) return 'Enter your email';
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Enter phone number' : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) => value!.length < 6 ? 'Password must be at least 6 characters' : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) => value != passwordController.text ? 'Passwords do not match' : null,
                    ),
                    const SizedBox(height: 15),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: _showTermsError ? Colors.red.withOpacity(0.08) : Colors.transparent,
                        borderRadius: BorderRadius.circular(5),
                      ),

                      child: Row(
                        children: [
                          Checkbox(
                            value: _termsAccepted,
                            onChanged: (value) {
                              setState(() {
                                _termsAccepted = value!;
                                _showTermsError = false;
                              });
                            },
                          ),
                          const Expanded(
                            child: Text(
                              'I accept the Terms and Conditions',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_showTermsError)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 4),
                        child: Row(
                          children: const [
                            Icon(Icons.error_outline, size: 16, color: Colors.red),
                            SizedBox(width: 4),
                            Text(
                              'Please accept the terms to continue.',
                              style: TextStyle(color: Colors.red, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 15),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          textStyle: const TextStyle(fontSize: 18),
                          minimumSize: const Size(200, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
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
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text('Sign In', style: TextStyle(color: Colors.green)),
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
