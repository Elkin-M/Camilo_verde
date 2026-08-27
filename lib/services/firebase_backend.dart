import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:camilo_verde/config/backend_config.dart';

class FirebaseBackend {
  static Future<void> initialize() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: BackendConfig.options);
    }
  }

  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
}
