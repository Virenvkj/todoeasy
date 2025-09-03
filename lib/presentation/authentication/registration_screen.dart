import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todoeasy/models/user_details.dart';
import 'package:todoeasy/presentation/home/dashboard_screen.dart';
import 'package:todoeasy/utils/app_constants.dart';
import 'package:todoeasy/utils/firestore_collections.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

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
    // Check minimum length
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    // Regular expression to check:
    // - At least one uppercase letter (?=.*[A-Z])
    // - At least one special character (?=.*[!@#$%^&*(),.?":{}|<>])
    // - Minimum 6 characters {6,}
    final passwordRegex =
        RegExp(r'^(?=.*[A-Z])(?=.*[!@#$%^&*(),.?":{}|<>]).{6,}$');

    if (!passwordRegex.hasMatch(value)) {
      if (!RegExp(r'[A-Z]').hasMatch(value)) {
        return 'Password must contain at least one uppercase letter';
      }
      if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
        return 'Password must contain at least one special character';
      }
    }

    return null;
  }

  Future<void> _storeUserData({
    required UserDetails userDetails,
  }) async {
    final firestore = FirebaseFirestore.instance;
    await firestore
        .collection(FirestoreCollections.userCollection)
        .doc(userDetails.uid)
        .set(
          userDetails.toJson(),
        );

    await firestore
        .collection(FirestoreCollections.todoListCollection)
        .doc(userDetails.uid)
        .set({});
  }

  Future<void> _signInAsGuest() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final firebaseAuth = FirebaseAuth.instance;
      final userCredentials = await firebaseAuth.signInAnonymously();

      if (userCredentials.user == null) {
        throw Exception('Somethign went wrong');
      }

      await _storeUserData(
        userDetails: UserDetails(
          uid: userCredentials.user!.uid,
          isGuest: true,
        ),
      );

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const DashboardScreen(),
        ),
        (route) => false,
      );

      AppConstans.showSnackBar(
        context,
        message: 'Account creation successful',
        isSuccess: true,
      );
    } catch (error) {
      AppConstans.showSnackBar(
        context,
        message: error.toString(),
        isSuccess: false,
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _handleRegistration() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final firebaseAuth = FirebaseAuth.instance;
        final userCredentials =
            await firebaseAuth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (userCredentials.user == null) {
          throw Exception('Somethign went wrong');
        }

        await _storeUserData(
          userDetails: UserDetails(
            uid: userCredentials.user!.uid,
            email: userCredentials.user!.email ?? _emailController.text.trim(),
            password: _passwordController.text.trim(),
          ),
        );

        if (!mounted) return;

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const DashboardScreen(),
          ),
          (route) => false,
        );

        AppConstans.showSnackBar(
          context,
          message: 'Account creation successful',
          isSuccess: true,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          AppConstans.showSnackBar(
            context,
            message: 'Password is too weak',
            isSuccess: false,
          );
        } else if (e.code == 'email-already-in-use') {
          AppConstans.showSnackBar(
            context,
            message: 'Email already in use',
            isSuccess: false,
          );
        }
      } catch (error) {
        AppConstans.showSnackBar(
          context,
          message: error.toString(),
          isSuccess: false,
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
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
                const SizedBox(height: 32),

                // Welcome text
                Text(
                  'Join TodoEasy',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your account to get started',
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
                  textInputAction: TextInputAction.next,
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

                const SizedBox(height: 32),

                // Register button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegistration,
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
                          'Create Account',
                          style: TextStyle(fontSize: 16),
                        ),
                ),

                const SizedBox(height: 16),

                // Guest button
                ElevatedButton(
                  onPressed: _isLoading ? null : _signInAsGuest,
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
                          'Enter as Guest',
                          style: TextStyle(fontSize: 16),
                        ),
                ),

                const SizedBox(height: 16),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Sign In'),
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
