import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todoeasy/presentation/authentication/login_screen.dart';
import 'package:todoeasy/utils/app_constants.dart';
import 'package:todoeasy/utils/firestore_collections.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> fetchUserProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) await _logout();

    // final userProfile = await FirebaseFirestore.instance
    //     .collection(
    //       FirestoreCollections.userCollection,
    //     )
    //     .where('email', isEqualTo: currentUser!.email)
    //     .get();

    final userProfile = await FirebaseFirestore.instance
        .collection(FirestoreCollections.userCollection)
        .doc(currentUser!.uid)
        .get();

    print(
      userProfile.data(),
    );
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
          (route) => false);
    } catch (e) {
      if (!mounted) return;
      AppConstans.showSnackBar(
        isSuccess: false,
        context,
        message: 'Error logging out',
      );
    }
  }

  @override
  void initState() {
    fetchUserProfile();
    super.initState();
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

            const Spacer(),

            // Logout Button
            ElevatedButton(
              onPressed: () async => _logout(),
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
}
