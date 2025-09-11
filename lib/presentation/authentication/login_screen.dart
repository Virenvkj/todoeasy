import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:todoeasy/presentation/authentication/registration_screen.dart';
import 'package:todoeasy/utils/app_constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final firebaseAuth = FirebaseAuth.instance;
  final googleSignIn = GoogleSignIn();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    final passwordRegex =
        RegExp(r'^(?=.*[A-Z])(?=.*[!@#$%^&*(),.?":{}|<>]).{6,}$');

    if (!passwordRegex.hasMatch(value)) {
      return 'Password is invalid';
    }

    return null;
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // First, sign out any existing Google account to force account picker
      await googleSignIn.signOut();
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      // If user cancels the sign-in
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        AppConstans.showSnackBar(
          context,
          message: 'Google Sign-In was cancelled',
          isSuccess: false,
        );
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      await firebaseAuth.signInWithCredential(credential);

      if (!mounted) return;
      
      AppConstans.showSnackBar(
        context,
        message: 'Google Sign-In successful!',
        isSuccess: true,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage = 'An account already exists with the same email address but different sign-in credentials.';
          break;
        case 'invalid-credential':
          errorMessage = 'The credential received is malformed or has expired.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Google Sign-In is not enabled for this project.';
          break;
        case 'user-disabled':
          errorMessage = 'The user account has been disabled.';
          break;
        default:
          errorMessage = 'Firebase Auth error: ${e.message}';
      }
      
      log('Firebase Auth Exception: ${e.code} - ${e.message}');
      if (mounted) {
        AppConstans.showSnackBar(
          context,
          message: errorMessage,
          isSuccess: false,
        );
      }
    } on PlatformException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'sign_in_failed':
          errorMessage = 'Google Sign-In failed. Error details: ${e.details}. Code: ${e.code}. Message: ${e.message}';
          break;
        case 'sign_in_canceled':
          errorMessage = 'Google Sign-In was cancelled.';
          break;
        case 'sign_in_required':
          errorMessage = 'Google Sign-In is required.';
          break;
        case 'network_error':
          errorMessage = 'Network error. Please check your connection.';
          break;
        default:
          errorMessage = 'Google Sign-In error: ${e.message ?? e.code}. Details: ${e.details}';
      }
      
      log('Google Sign-In Platform Exception: ${e.code} - ${e.message} - Details: ${e.details}');
      if (mounted) {
        AppConstans.showSnackBar(
          context,
          message: errorMessage,
          isSuccess: false,
        );
      }
    } catch (e) {
      log('General Exception: ${e.toString()}');
      if (mounted) {
        AppConstans.showSnackBar(
          context,
          message: 'An unexpected error occurred: ${e.toString()}',
          isSuccess: false,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSignIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await firebaseAuth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (!mounted) return;

        AppConstans.showSnackBar(
          context,
          message: 'Login successful',
          isSuccess: true,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'invalid-credential') {
          AppConstans.showSnackBar(
            context,
            isSuccess: false,
            message: 'Incorrect email or password',
          );
        } else {
          AppConstans.showSnackBar(
            context,
            isSuccess: false,
            message: e.toString(),
          );
        }
      } catch (e) {
        AppConstans.showSnackBar(
          context,
          message: e.toString(),
          isSuccess: false,
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToRegistration() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegistrationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 80),

                // App logo or icon (optional)
                Icon(
                  Icons.check_circle_outline,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),

                const SizedBox(height: 32),

                // Welcome text
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to your TodoEasy account',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: _validateEmail,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email address',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  textInputAction: TextInputAction.done,
                  validator: _validatePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 8),

                // Forgot password link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Navigate to forgot password screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Forgot password functionality coming soon!'),
                        ),
                      );
                    },
                    child: const Text('Forgot Password?'),
                  ),
                ),

                const SizedBox(height: 24),

                // Sign in button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignIn,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Sign In',
                          style: TextStyle(fontSize: 16),
                        ),
                ),

                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 24),

                // Sign in button
                ElevatedButton(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Continue with Google',
                          style: TextStyle(fontSize: 16),
                        ),
                ),

                const SizedBox(height: 24),

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: _navigateToRegistration,
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
