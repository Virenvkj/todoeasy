import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:todoeasy/models/user_details.dart';
import 'package:todoeasy/presentation/authentication/login_screen.dart';
import 'package:todoeasy/utils/app_constants.dart';
import 'package:todoeasy/utils/firestore_collections.dart';
import 'package:todoeasy/widgets/logout_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserDetails? currentUserDetails;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  final currentUser = FirebaseAuth.instance.currentUser;
  final googleSignIn = GoogleSignIn();

  Future<void> fetchUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    if (currentUser == null) await _logout();

    final userProfile = await FirebaseFirestore.instance
        .collection(FirestoreCollections.userCollection)
        .doc(currentUser?.uid)
        .get();

    if (userProfile.data() == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    } else {
      currentUserDetails = UserDetails.fromJson(userProfile.data()!);
      firstNameController =
          TextEditingController(text: currentUserDetails?.firstName);
      lastNameController =
          TextEditingController(text: currentUserDetails?.lastName);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });
    final firestore = FirebaseFirestore.instance;
    currentUserDetails?.firstName = firstNameController.text.trim();
    currentUserDetails?.lastName = lastNameController.text.trim();

    if (currentUserDetails == null) {
      setState(() {
        _isLoading = true;
      });
      return;
    } else {
      await firestore
          .collection(FirestoreCollections.userCollection)
          .doc(currentUser?.uid)
          .update(currentUserDetails!.profileNameToJson());
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      await googleSignIn.signOut();

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

  bool isSaveEnabled() {
    if (_formKey.currentState == null) return false;
    return _formKey.currentState!.validate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.all(24.0).copyWith(top: 10),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : currentUserDetails == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text('No details found'),
                        LogoutCta(
                          onLogout: () async => _logout(),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
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
                        Text(
                          currentUserDetails?.email ?? 'No email',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Welcome to TodoEasy',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 60),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                onChanged: (value) {
                                  setState(() {});
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                controller: firstNameController,
                                keyboardType: TextInputType.name,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'First name cannot be empty';
                                  }
                                  if (value.length < 3) {
                                    return 'First name is invalid';
                                  }

                                  return null;
                                },
                                decoration: const InputDecoration(
                                  labelText: 'First name',
                                  hintText: 'Enter your First name',
                                  prefixIcon: Icon(Icons.account_box),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                onChanged: (value) {
                                  setState(() {});
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                controller: lastNameController,
                                keyboardType: TextInputType.name,
                                textInputAction: TextInputAction.done,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Last name cannot be empty';
                                  }
                                  if (value.length < 3) {
                                    return 'Last name is invalid';
                                  }

                                  return null;
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Last name',
                                  hintText: 'Enter your Last name',
                                  prefixIcon: Icon(Icons.account_box),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: isSaveEnabled()
                                    ? () async {
                                        await _saveProfile();
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
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
                                      'Save',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        //Logout CTA
                        LogoutCta(
                          onLogout: () async => _logout(),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
      ),
    );
  }
}
