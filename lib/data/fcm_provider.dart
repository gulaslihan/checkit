import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'local_notifications.dart';
import 'notification_navigation.dart';
import 'notification_settings_provider.dart';

/// Requests notification permission and stores this device's FCM token on
/// the user's `users/{uid}` doc, so a Cloud Function can push to it later.
/// Safe to call every time the user becomes signed-in/verified — Firestore
/// merge-writes make repeat calls harmless, and `onTokenRefresh` keeps the
/// stored token current if it ever rotates.
Future<void> registerFcmToken(String uid) async {
  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(alert: true, badge: true, sound: true);

  final token = await messaging.getToken();
  if (token != null) {
    await usersCollection.doc(uid).set({'fcmToken': token}, SetOptions(merge: true));
  }

  messaging.onTokenRefresh.listen((newToken) {
    usersCollection.doc(uid).set({'fcmToken': newToken}, SetOptions(merge: true));
  });
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
