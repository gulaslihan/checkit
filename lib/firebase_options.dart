// Firebase config for the CheckIt project — apps registered by hand via the
// Firebase Console (CLI login isn't available in this environment).
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'iOS henüz Firebase Console\'da kaydedilmedi — bir Mac ile derlemeye geçince eklenecek.',
        );
      default:
        throw UnsupportedError('Bu platform için Firebase yapılandırması yok.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCDK3HNRfz9beH48OidSX_L7iMgkz2rKcw',
    appId: '1:675044482932:web:46a971d881a490f5551621',
    messagingSenderId: '675044482932',
    projectId: 'checkit-bb0e7',
    authDomain: 'checkit-bb0e7.firebaseapp.com',
    storageBucket: 'checkit-bb0e7.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDgKcZdSYCCUD_nO3LurMwBJ3RZPk_o5zA',
    appId: '1:675044482932:android:f28a887aa9efedfc551621',
    messagingSenderId: '675044482932',
    projectId: 'checkit-bb0e7',
    storageBucket: 'checkit-bb0e7.firebasestorage.app',
  );
}
