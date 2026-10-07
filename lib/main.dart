import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/fcm_provider.dart';
import 'data/local_notifications.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Already the default on Android/iOS — explicit here mainly for the web
  // build, where offline persistence is off unless enabled: without this, a
  // change made while offline (e.g. checking off an item) only updates once
  // the app is closed and reopened with a connection, not automatically the
  // moment connectivity comes back.
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  await initializeLocalNotifications();
  listenForPushNotifications();
  runApp(const ProviderScope(child: CheckItApp()));
}
