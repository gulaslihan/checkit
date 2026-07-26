import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

/// Turns a caught error into a short Turkish message safe to show a user —
/// callers should never interpolate a raw exception into a SnackBar (that
/// leaks technical text like "[cloud_firestore/permission-denied] ...").
String friendlyErrorMessage(Object error) {
  if (error is FirebaseException) {
    switch (error.code) {
      case 'permission-denied':
        return 'Bu işlem için yetkiniz yok.';
      case 'unavailable':
        return 'Bağlantı sorunu — internetinizi kontrol edip tekrar deneyin.';
      case 'not-found':
        return 'Aradığınız kayıt bulunamadı.';
    }
  }
  return 'Bir şeyler ters gitti, lütfen tekrar deneyin.';
}

/// Runs [action] and, if it throws, shows a friendly SnackBar instead of
/// letting the failure vanish silently — release builds show no visible
/// error otherwise, so a failed write looks exactly like a successful one.
/// Returns whether [action] completed without throwing, so callers can skip
/// any success-only follow-up (closing a sheet, showing a success message).
Future<bool> runGuarded(BuildContext context, Future<void> Function() action) async {
  try {
    await action();
    return true;
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyErrorMessage(e))),
      );
    }
    return false;
  }
}
