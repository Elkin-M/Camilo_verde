import 'package:firebase_core/firebase_core.dart';

class BackendConfig {
  static const projectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'camilo-verde-87f45',
  );
  static const apiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'AIzaSyAWjZ5XH8DCXoYnBRheJ2dIO390p7-qdtE',
  );
  static const appId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: '1:910372806757:android:4b19988019a08005a8268c',
  );
  static const messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '910372806757',
  );
  static const driveUploadEndpoint = String.fromEnvironment(
    'DRIVE_UPLOAD_ENDPOINT',
    defaultValue: 'https://script.google.com/macros/s/AKfycbwoH0wrAVnaGi-fLCyiLZFx40osgY5kI5Crx_vt4wa6C2GZ-3JX0OvUjfyh_1MvfBaHig/exec',
  );

  static FirebaseOptions get options => FirebaseOptions(
        apiKey: apiKey,
        appId: appId,
        messagingSenderId: messagingSenderId,
        projectId: projectId,
        storageBucket: null,
      );
}
