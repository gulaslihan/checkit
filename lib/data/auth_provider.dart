import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// userChanges() (not authStateChanges()) so that calling user.reload() after
/// an email-verification link is clicked actually updates emailVerified here.
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.userChanges();
});
