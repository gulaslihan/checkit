import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'local_notifications.dart';
import 'notification_navigation.dart';
import 'notification_settings_provider.dart';

StreamSubscription<String>? _tokenRefreshSub;

/// Saves [token] on the user's doc through the `registerFcmToken` Cloud
/// Function, which also strips the same token from any other account's doc (a
/// token belongs to a device, not an account). Falls back to a plain write if
/// the function can't be reached or the doc doesn't exist yet.
Future<void> _saveToken(String uid, String token) async {
  try {
    final result = await FirebaseFunctions.instance.httpsCallable('registerFcmToken').call<Map<String, dynamic>>({'token': token});
    if (Map<String, dynamic>.from(result.data as Map)['stored'] == true) return;
  } catch (_) {
    // fall through to the direct write below
  }
  await usersCollection.doc(uid).set({'fcmToken': token}, SetOptions(merge: true));
}

/// Requests notification permission and stores this device's FCM token on
/// the user's `users/{uid}` doc, so a Cloud Function can push to it later.
/// Safe to call every time the user becomes signed-in/verified, and
/// `onTokenRefresh` keeps the stored token current if it ever rotates.
Future<void> registerFcmToken(String uid) async {
  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(alert: true, badge: true, sound: true);

  final token = await messaging.getToken();
  if (token != null) await _saveToken(uid, token);

  await _tokenRefreshSub?.cancel();
  _tokenRefreshSub = messaging.onTokenRefresh.listen((newToken) => _saveToken(uid, newToken));
}

/// Call right BEFORE signing out (or after an account was deleted): detaches
/// this device from the account so the account's pushes stop arriving here.
/// Without it the token stays on the old account's doc and, when someone else
/// signs in on this phone, the previous account's notifications keep landing
/// on it. Every step is best-effort — signing out must never be blocked by it.
Future<void> detachDeviceFromAccount({String? uid}) async {
  await _tokenRefreshSub?.cancel();
  _tokenRefreshSub = null;
  if (uid != null) {
    try {
      await usersCollection.doc(uid).update({'fcmToken': FieldValue.delete()});
    } catch (_) {}
  }
  try {
    await FirebaseMessaging.instance.deleteToken();
  } catch (_) {}
  try {
    await cancelAllDueDateReminders();
  } catch (_) {}
}

/// Call once at startup. Cloud Functions pushes (see functions/index.js) only
/// auto-display as a tray notification when the app is backgrounded or
/// terminated, so foreground arrivals are surfaced manually here; tapping a
/// push in any app state routes to the relevant screen via
/// [handleNotificationTapData].
void listenForPushNotifications() {
  FirebaseMessaging.onMessage.listen((message) {
    final notification = message.notification;
    if (notification == null) return;
    showPushNotification(
      title: notification.title ?? 'CheckIt',
      body: notification.body ?? '',
      data: message.data,
    );
  });

  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    handleNotificationTapData(message.data);
  });

  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null) handleNotificationTapData(message.data);
  });
}
