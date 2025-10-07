
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ims/components/my_button.dart';
import 'package:ims/components/my_textfield.dart';
import 'package:email_validator/email_validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  bool validateEmail(String email) {
    return EmailValidator.validate(email);
  }

  bool validatePassword(String password) {
    return password.length >= 6;
  }

  void signUserIn() async {
    if (!validateEmail(emailController.text)) {
      showErrorDialog('Invalid Email', 'Please enter a valid email address.');
      return;
    }

    if (!validatePassword(passwordController.text)) {
      showErrorDialog('Invalid Password', 'Password must be at least 6 characters long.');
      return;
    }

    showLoadingDialog();

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).get();
      if (!userDoc.exists) {
        showErrorDialog('User Not Found', 'User document not found. Please register.');
        FirebaseAuth.instance.signOut();
      } else {
        final userRole = userDoc['role'];
        if (mounted) {
          Navigator.pop(context);
          if (userRole == 'admin') {
            Navigator.pushReplacementNamed(context, '/admin_home');
          } else {
            Navigator.pushReplacementNamed(context, '/user_home');
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showErrorDialog('Login Failed', e.message ?? 'An error occurred while logging in. Please try again.');
      }
    }
  }

  void showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  void handleForgotPassword() async {
    if (emailController.text.isEmpty) {
      showErrorDialog('Email Required', 'Please enter your email to reset password.');
      return;
    }

    showLoadingDialog();

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text);
      if (mounted) {
        Navigator.pop(context);
        showErrorDialog('Reset Email Sent', 'A password reset email has been sent to your email address.');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showErrorDialog('Reset Email Failed', e.message ?? 'An error occurred while sending the reset email.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Gradient Background
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: const [Colors.blue, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.0, _animationController.value],
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      // Lottie Animation
                      Lottie.network(
                        'https://assets6.lottiefiles.com/packages/lf20_gjmecwoc.json',
                        width: 200,
                        height: 200,
                      ).animate().fade(duration: 500.ms).scale(delay: 500.ms),
                      const SizedBox(height: 20),
                      const Text(
                        'Welcome Back!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().fade(duration: 500.ms).slideY(begin: -1, end: 0),
                      const SizedBox(height: 10),
                      Text(
                        'Sign in to continue',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ).animate().fade(duration: 500.ms).slideY(begin: 1, end: 0),
                      const SizedBox(height: 40),
                      // Glassmorphism Card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              children: [
                                MyTextField(controller: emailController, hintText: 'Email', obscureText: false),
                                const SizedBox(height: 20),
                                MyTextField(controller: passwordController, hintText: 'Password', obscureText: true),
                                const SizedBox(height: 20),
                                GestureDetector(
                                  onTap: handleForgotPassword,
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(height: 30),
                                MyButton(onTap: signUserIn, text: 'Sign In'),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fade(duration: 500.ms).scale(delay: 700.ms),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Not a member?', style: TextStyle(color: Colors.white.withOpacity(0.8))),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: widget.onTap,
                            child: const Text('Register now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ).animate().fade(duration: 500.ms, delay: 900.ms),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
