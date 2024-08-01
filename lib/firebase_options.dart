// lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC6fHCsWv4MdPgY1tKMsB7phSbJ87z1-1I',
    authDomain: 'lets-catchup-1.firebaseapp.com',
    projectId: 'lets-catchup-1',
    storageBucket: 'lets-catchup-1.appspot.com',
    messagingSenderId: '217405488344',
    appId: '1:217405488344:web:6028d561fdaed38be16bad',
    measurementId: 'G-C60449YP84',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC6fHCsWv4MdPgY1tKMsB7phSbJ87z1-1I',
    authDomain: 'lets-catchup-1.firebaseapp.com',
    projectId: 'lets-catchup-1',
    storageBucket: 'lets-catchup-1.appspot.com',
    messagingSenderId: '217405488344',
    appId: '1:217405488344:web:6028d561fdaed38be16bad',
    measurementId: 'G-C60449YP84',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC6fHCsWv4MdPgY1tKMsB7phSbJ87z1-1I',
    authDomain: 'lets-catchup-1.firebaseapp.com',
    projectId: 'lets-catchup-1',
    storageBucket: 'lets-catchup-1.appspot.com',
    messagingSenderId: '217405488344',
    appId: '1:217405488344:web:6028d561fdaed38be16bad',
    measurementId: 'G-C60449YP84',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC6fHCsWv4MdPgY1tKMsB7phSbJ87z1-1I',
    authDomain: 'lets-catchup-1.firebaseapp.com',
    projectId: 'lets-catchup-1',
    storageBucket: 'lets-catchup-1.appspot.com',
    messagingSenderId: '217405488344',
    appId: '1:217405488344:web:6028d561fdaed38be16bad',
    measurementId: 'G-C60449YP84',
  );
}
