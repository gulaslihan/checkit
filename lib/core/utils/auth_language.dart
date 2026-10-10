import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

/// Tells Firebase which language to write the next auth e-mail in (the
/// verification / password-reset message AND the hosted page its link opens).
/// Without this Firebase defaults to English, so a Turkish user got an English
/// e-mail and an English "Verify Email Address" page. Uses the language the
/// app is currently showing, so a manual override in Profile > Dil and the
/// device language are both respected. Call right before sending.
Future<void> useAuthEmailLanguage(BuildContext context) {
  final code = Localizations.localeOf(context).languageCode;
  return FirebaseAuth.instance.setLanguageCode(code == 'tr' ? 'tr' : 'en');
}
