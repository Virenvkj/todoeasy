import 'package:flutter/material.dart';

class AppConstans {
  AppConstans._();

  static showSnackBar(
    BuildContext context, {
    required String message,
    bool isSuccess = true,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
