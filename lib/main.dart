import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:todoeasy/firebase_options.dart';
import 'package:todoeasy/myapp.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await requestNotificationPermission();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  if (!kIsWeb) {
    await setupFlutterNotifications();
  }

  runApp(const MyApp());
}

Future<void> requestNotificationPermission() async {
  await Permission.notification.request();
}

Future<void> setupFlutterNotifications() async {
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await setupFlutterNotifications();
}

/// Notifications setup
/// 1. Install permissions_handler
/// 2. Request for notification permissions
/// 3. Install firebase_messaging
/// 4. Setup background notification handler functions
/// 4. Setup campaign on firebase
/// 5. Get the FCM token
/// 6. Make a test using firebase campaign