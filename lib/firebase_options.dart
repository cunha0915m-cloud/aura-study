// PLACEHOLDER: gera o ficheiro real com `flutterfire configure`.
// Este ficheiro serve apenas para o projeto compilar antes da configuração.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _android;
      case TargetPlatform.iOS:
        return _ios;
      default:
        return _web;
    }
  }

  static const FirebaseOptions _android = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
  );

  static const FirebaseOptions _ios = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
    iosBundleId: 'com.aurastudy.app',
  );

  static const FirebaseOptions _web = FirebaseOptions(
    apiKey: "AIzaSyBliFGV6ooWOxBPsKgbt1ZqXGiA5pNqCRs",
    authDomain: "aura-study-265db.firebaseapp.com",
    projectId: "aura-study-265db",
    storageBucket: "aura-study-265db.firebasestorage.app",
    messagingSenderId: "884212558604",
    appId: "1:884212558604:web:d5561aca5893cfc404f729",
    measurementId: "G-JQGB9X9HK1",
  );
}
