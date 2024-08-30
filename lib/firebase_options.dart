
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;


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
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyA6moTsTSwgmMvzaUE6GkhJFFWb80TChNA',
    appId: '1:752558525953:web:943f4eebc9efb3e870ba00',
    messagingSenderId: '752558525953',
    projectId: 'aaaa-3261d',
    authDomain: 'aaaa-3261d.firebaseapp.com',
    databaseURL: 'https://aaaa-3261d-default-rtdb.firebaseio.com',
    storageBucket: 'aaaa-3261d.appspot.com',
    measurementId: 'G-GCE3CQ5JL3',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCrKJ0IJlwStE_BEYaoXmcU_cIhdJMpC90',
    appId: '1:752558525953:android:d242a335ef9f51a570ba00',
    messagingSenderId: '752558525953',
    projectId: 'aaaa-3261d',
    databaseURL: 'https://aaaa-3261d-default-rtdb.firebaseio.com',
    storageBucket: 'aaaa-3261d.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBnnNEU6U8sCcq02RHbqHjWZ1HpB389BeM',
    appId: '1:752558525953:ios:71291ba777fc69cc70ba00',
    messagingSenderId: '752558525953',
    projectId: 'aaaa-3261d',
    databaseURL: 'https://aaaa-3261d-default-rtdb.firebaseio.com',
    storageBucket: 'aaaa-3261d.appspot.com',
    iosBundleId: 'com.example.untitled',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBnnNEU6U8sCcq02RHbqHjWZ1HpB389BeM',
    appId: '1:752558525953:ios:6d722fa9c9b0388f70ba00',
    messagingSenderId: '752558525953',
    projectId: 'aaaa-3261d',
    databaseURL: 'https://aaaa-3261d-default-rtdb.firebaseio.com',
    storageBucket: 'aaaa-3261d.appspot.com',
    iosBundleId: 'com.example.untitled.RunnerTests',
  );
}
