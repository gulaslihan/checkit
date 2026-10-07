import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'notification_settings_provider.dart';

/// Writes the effective app language ('tr' or 'en') to `users/{uid}` so
/// Cloud Functions can pick the right language for push notification text
/// (see functions/index.js) — mirrors [LocaleNotifier]'s resolution: the
/// manual override if set, otherwise the device's own reported language.
Future<void> syncLanguagePreference(String uid, Locale? localeOverride) async {
  final code = localeOverride?.languageCode ?? PlatformDispatcher.instance.locale.languageCode;
  final language = code == 'tr' ? 'tr' : 'en';
  await usersCollection.doc(uid).set({'language': language}, SetOptions(merge: true));
}
