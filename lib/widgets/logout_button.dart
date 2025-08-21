import 'package:flutter/material.dart';

class LogoutCta extends StatelessWidget {
  const LogoutCta({
    super.key,
    required this.onLogout,
  });

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onLogout,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        minimumSize: const Size(double.infinity, 50),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout),
          SizedBox(width: 8),
          Text(
            'Logout',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
