import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ims/components/my_button.dart';
import 'package:ims/components/my_textfield.dart';
import 'package:email_validator/email_validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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

      // Check if the user document exists in Firestore
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).get();
      if (!userDoc.exists) {
        // Handle the case where the user document doesn't exist (should not happen if registration is properly implemented)
        showErrorDialog('User Not Found', 'User document not found. Please register.');
        FirebaseAuth.instance.signOut();
      } else {
        // Navigate to home page based on user role
        final userRole = userDoc['role'];
        if (mounted) {
          Navigator.pop(context);  // Dismiss loading dialog
          // Example of routing based on role
          if (userRole == 'admin') {
            Navigator.pushNamed(context, '/admin_home');
          } else {
            Navigator.pushNamed(context, '/user_home');
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.pop(context);  // Dismiss loading dialog
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
              onPressed: () {
                Navigator.pop(context);
              },
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
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text,
      );

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
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  const Icon(Icons.lock, size: 100),
                  const SizedBox(height: 50),
                  Text(
                    'Welcome back you\'ve been missed!',
                    style: TextStyle(color: Colors.grey[700], fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),
                  MyTextField(controller: emailController, hintText: 'Email', obscureText: false),
                  const SizedBox(height: 20),
                  MyTextField(controller: passwordController, hintText: 'Password', obscureText: true),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: handleForgotPassword,
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 20),
                  MyButton(onTap: signUserIn, text: 'Sign In'),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Not a member?', style: TextStyle(color: Colors.grey[700])),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text('Register now', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
