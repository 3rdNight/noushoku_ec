import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for android - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAwKJ-9tPqppU3DoFAu15xB4LuDxgKxdd8',
    appId: '1:403270423889:web:845c97385700d34f3e2f70',
    messagingSenderId: '403270423889',
    projectId: 'noushoku-ec',
    authDomain: 'noushoku-ec.firebaseapp.com',
    storageBucket: 'noushoku-ec.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAwKJ-9tPqppU3DoFAu15xB4LuDxgKxdd8',
    appId: '1:403270423889:web:95059b73633789c63e2f70',
    messagingSenderId: '403270423889',
    projectId: 'noushoku-ec',
    authDomain: 'noushoku-ec.firebaseapp.com',
    storageBucket: 'noushoku-ec.firebasestorage.app',
  );
}
