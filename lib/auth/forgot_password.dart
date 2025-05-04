import 'package:cashcare/utils/snackbar_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:cashcare/auth/login_screen.dart';
import 'package:cashcare/auth/signup_screen.dart';
import 'package:cashcare/services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _sendResetLink() async {
    // Clear previous errors
    setState(() => _errorMessage = null);

    final email = _emailController.text.trim();

    // Validate email
    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email address');
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() => _errorMessage = 'Please enter a valid email address');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final error = await AuthService.sendPasswordResetEmail(email);

      if (!mounted) return;

      if (error != null) {
        setState(() => _errorMessage = error);
      } else {
        // Show success dialog

        SnackBarService.showCustomSnackBar(context: context, message: 'We\'ve sent a password reset link to your email.', icon: Icon(Icons.check_circle_outline), backgroundColor: Colors.green, textColor: Colors.white);


        // Navigate back to login
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      }
    } catch (e) {
      setState(() => _errorMessage = 'An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(IconlyBold.arrowLeftCircle, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/forgotpasslogo.png',
                height: 200,
                width: 200,
              ),
              const SizedBox(height: 20),
              Text(
                "Forgot Your Password?",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Enter your registered email below to receive a password reset link.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: "Email Address",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 20,
                  ),
                  errorText: _errorMessage,
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => setState(() => _errorMessage = null),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendResetLink,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                      : const Text(
                    'Send Reset Link',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (builder) => const SignupPage()),
                    ),
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