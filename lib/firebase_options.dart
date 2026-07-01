import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web not supported');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('This platform is not supported');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB8byESO6Xn7SYNqidgIOFjG3Tm7He1UEg',
    appId: '1:929286892992:android:dfd8ae6cf50ede5c7dec25',
    messagingSenderId: '929286892992',
    projectId: 'expense-tracker-b3ea7',
    storageBucket: 'expense-tracker-b3ea7.firebasestorage.app',
  );
}
