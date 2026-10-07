// Firebase config for the CheckIt project — apps registered via the Firebase
// Console / `firebase apps:create` (see firebase.json project checkit-bb0e7).
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
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

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDBKjMv4t0skiQOBqJYC6x2Wm0302praNw',
    appId: '1:675044482932:ios:c58afb9ab421d306551621',
    messagingSenderId: '675044482932',
    projectId: 'checkit-bb0e7',
    storageBucket: 'checkit-bb0e7.firebasestorage.app',
    iosBundleId: 'com.velanalytics.checkit',
  );

  // Re-registered 20 Eylül 2026 under com.velanalytics.checkit —
  // com.checkit.checkit was already taken by another developer on Play
  // Store. The old app registration (appId ending 551621) is left in place
  // in Firebase Console, just unused now.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDgKcZdSYCCUD_nO3LurMwBJ3RZPk_o5zA',
    appId: '1:675044482932:android:08d3d9d8587cf7e3551621',
    messagingSenderId: '675044482932',
    projectId: 'checkit-bb0e7',
    storageBucket: 'checkit-bb0e7.firebasestorage.app',
  );
}
