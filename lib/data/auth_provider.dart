import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// userChanges() (not authStateChanges()) so that calling user.reload() after
/// an email-verification link is clicked actually updates emailVerified here.
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.userChanges();
});

/// Turns FirebaseAuth's English exception codes into short Turkish messages.
String authErrorMessage(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-email':
      return 'E-posta adresi geçersiz görünüyor.';
    case 'user-disabled':
      return 'Bu hesap devre dışı bırakılmış.';
    case 'user-not-found':
      return 'Bu e-posta ile kayıtlı bir hesap bulunamadı.';
    case 'wrong-password':
    case 'invalid-credential':
      return 'E-posta veya şifre hatalı.';
    case 'email-already-in-use':
      return 'Bu e-posta zaten kullanımda, giriş yapmayı deneyin.';
    case 'weak-password':
      return 'Şifre en az 6 karakter olmalı.';
    case 'too-many-requests':
      return 'Çok fazla deneme yapıldı, biraz sonra tekrar deneyin.';
    case 'operation-not-allowed':
      return 'E-posta/şifre girişi Firebase Console\'da henüz açılmamış.';
    default:
      return 'Bir şeyler ters gitti: ${e.message ?? e.code}';
  }
}
