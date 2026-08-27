import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:camilo_verde/models/admin_content.dart';
import 'package:camilo_verde/services/firebase_backend.dart';

class PublicContentRepository {
  CollectionReference<Map<String, dynamic>> _collection(String name) =>
      FirebaseBackend.firestore.collection(name);

  Future<List<AdminNews>> getNews() async {
    final snapshot = await _collection('news').get();
    final items = snapshot.docs.where((d) => d.data()['published'] != false).map((d) { final x = d.data(); return AdminNews(id: d.id, title: x['title'] ?? '', imageUrl: x['imageUrl'] ?? '', dateText: x['dateText'] ?? '', body: x['body'] ?? ''); }).toList();
    items.sort((a, b) => _parseDate(b.dateText).compareTo(_parseDate(a.dateText)));
    return items;
  }

  Future<List<AdminEvent>> getEvents() async {
    final snapshot = await _collection('events').get();
    final items = snapshot.docs.where((d) => d.data()['published'] != false).map((d) { final x = d.data(); return AdminEvent(id: d.id, title: x['title'] ?? '', date: x['date'] ?? '', dateText: x['dateText'] ?? '', time: x['time'] ?? '', place: x['place'] ?? '', imageUrl: x['imageUrl'] ?? '', instructions: x['instructions'] ?? '', icon: x['icon'] ?? 'event'); }).toList();
    items.sort((a, b) => _parseDate(a.date).compareTo(_parseDate(b.date)));
    return items;
  }

  Future<List<AdminEvidence>> getEvidences() async {
    final snapshot = await _collection('evidences').get();
    return snapshot.docs.where((d) => d.data()['published'] != false).map((d) { final x = d.data(); final urls = x['mediaUrls'] ?? x['imageUrls'] ?? x['imagenes'] ?? const []; return AdminEvidence(id: d.id, title: x['title'] ?? x['nombre'] ?? '', date: x['date'] ?? x['fecha'] ?? '', mediaUrls: List<String>.from(urls is List ? urls : [urls.toString()]), description: x['description'] ?? x['desc'] ?? ''); }).toList();
  }

  Future<String?> getVideoUrl() async {
    final document = await _collection('settings').doc('home').get();
    return document.data()?['videoUrl'] as String?;
  }

  Future<Map<String, String>> getHomeCarousel() async {
    final document = await _collection('settings').doc('home').get();
    final data = document.data() ?? {};
    return {
      'imageUrl': data['carouselImageUrl']?.toString() ?? '',
      'title': data['carouselTitle']?.toString() ?? 'Proyecto Ambiental PRAE Camilo Verde',
      'description': data['carouselDescription']?.toString() ?? 'Descubre nuestras iniciativas ecológicas y los avances recientes de nuestra comunidad.',
    };
  }

  Future<List<AdminModel>> getModels() async {
    final snapshot = await _collection('models').where('active', isEqualTo: true).get();
    return snapshot.docs.map((d) { final x = d.data(); return AdminModel(id: d.id, title: x['title'] ?? '', url: x['url'] ?? '', active: x['active'] == true); }).toList();
  }

  DateTime _parseDate(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return parsed;
    final parts = value.split(RegExp(r'[/.-]'));
    if (parts.length == 3) {
      final first = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final last = int.tryParse(parts[2]);
      if (first != null && month != null && last != null) {
        return first > 31 ? DateTime(first, month, last) : DateTime(last > 31 ? last : 2000 + last, month, first);
      }
    }
    return DateTime(2000);
  }
}
