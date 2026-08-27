import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:camilo_verde/models/admin_content.dart';
import 'package:camilo_verde/services/firebase_backend.dart';

class PublicContentRepository {
  CollectionReference<Map<String, dynamic>> _collection(String name) =>
      FirebaseBackend.firestore.collection(name);

  Future<List<AdminNews>> getNews() async {
    final snapshot = await _collection('news').get();
    return snapshot.docs.where((d) => d.data()['published'] != false).map((d) { final x = d.data(); return AdminNews(id: d.id, title: x['title'] ?? '', imageUrl: x['imageUrl'] ?? '', dateText: x['dateText'] ?? '', body: x['body'] ?? ''); }).toList();
  }

  Future<List<AdminEvent>> getEvents() async {
    final snapshot = await _collection('events').get();
    return snapshot.docs.where((d) => d.data()['published'] != false).map((d) { final x = d.data(); return AdminEvent(id: d.id, title: x['title'] ?? '', date: x['date'] ?? '', dateText: x['dateText'] ?? '', time: x['time'] ?? '', place: x['place'] ?? '', imageUrl: x['imageUrl'] ?? '', instructions: x['instructions'] ?? '', icon: x['icon'] ?? 'event'); }).toList();
  }

  Future<List<AdminEvidence>> getEvidences() async {
    final snapshot = await _collection('evidences').get();
    return snapshot.docs.where((d) => d.data()['published'] != false).map((d) { final x = d.data(); final urls = x['mediaUrls'] ?? x['imageUrls'] ?? x['imagenes'] ?? const []; return AdminEvidence(id: d.id, title: x['title'] ?? x['nombre'] ?? '', date: x['date'] ?? x['fecha'] ?? '', mediaUrls: List<String>.from(urls is List ? urls : [urls.toString()]), description: x['description'] ?? x['desc'] ?? ''); }).toList();
  }

  Future<String?> getVideoUrl() async {
    final document = await _collection('settings').doc('home').get();
    return document.data()?['videoUrl'] as String?;
  }

  Future<List<AdminModel>> getModels() async {
    final snapshot = await _collection('models').where('active', isEqualTo: true).get();
    return snapshot.docs.map((d) { final x = d.data(); return AdminModel(id: d.id, title: x['title'] ?? '', url: x['url'] ?? '', active: x['active'] == true); }).toList();
  }
}
