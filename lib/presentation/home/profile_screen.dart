import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todoeasy/utils/app_constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        AppConstans.showSnackBar(
          context,
          message: 'Logged out successfully',
          isSuccess: true,
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppConstans.showSnackBar(
          context,
          message: 'Error logging out: ${e.toString()}',
          isSuccess: false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            
            // User Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.deepPurple.shade100,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.deepPurple.shade400,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // User Email
            Text(
              user?.email ?? 'No email',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Welcome to TodoEasy',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 60),
            
            // Profile Options
            _buildProfileOption(
              context,
              icon: Icons.person_outline,
              title: 'Account Settings',
              onTap: () {
                // TODO: Navigate to account settings
                AppConstans.showSnackBar(
                  context,
                  message: 'Account settings coming soon',
                  isSuccess: true,
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            _buildProfileOption(
              context,
              icon: Icons.notifications_none_outlined,
              title: 'Notifications',
              onTap: () {
                // TODO: Navigate to notifications settings
                AppConstans.showSnackBar(
                  context,
                  message: 'Notification settings coming soon',
                  isSuccess: true,
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            _buildProfileOption(
              context,
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {
                // TODO: Navigate to help
                AppConstans.showSnackBar(
                  context,
                  message: 'Help & Support coming soon',
                  isSuccess: true,
                );
              },
            ),
            
            const Spacer(),
            
            // Logout Button
            ElevatedButton(
              onPressed: () => _handleLogout(context),
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
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.deepPurple.shade400,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}