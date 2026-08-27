import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:camilo_verde/services/firebase_backend.dart';
import 'package:camilo_verde/services/drive_upload_service.dart';

class AdminContentRepository {
  final _db = FirebaseBackend.firestore;
  final _drive = DriveUploadService();

  Future<DocumentReference<Map<String, dynamic>>> create(String collection, Map<String, dynamic> data) async {
    try {
      final reference = await _db.collection(collection).add({
        ...data,
        'published': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      final saved = await reference.get();
      if (!saved.exists) {
        throw StateError('Firebase no confirmó el documento ${reference.path}.');
      }
      return reference;
    } on FirebaseException catch (error) {
      throw StateError('Firebase ${error.code}: ${error.message ?? 'rechazó la escritura.'}');
    }
  }

  Future<void> setHomeVideo(String url) => _db.collection('settings').doc('home').set({'videoUrl': url, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));

  Future<void> delete(String collection, String id, {List<String> fileIds = const []}) async {
    for (final fileId in fileIds) { await _drive.trash(fileId); }
    await _db.collection(collection).doc(id).delete();
  }
}
