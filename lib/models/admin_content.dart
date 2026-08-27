class AdminUser {
  const AdminUser({required this.uid, required this.email, required this.active, required this.role});
  final String uid;
  final String email;
  final bool active;
  final String role;
}

class AdminEvent {
  const AdminEvent({required this.id, required this.title, required this.date, required this.dateText, required this.time, required this.place, required this.imageUrl, required this.instructions, required this.icon});
  final String id;
  final String title;
  final String date;
  final String dateText;
  final String time;
  final String place;
  final String imageUrl;
  final String instructions;
  final String icon;
}

class AdminNews {
  const AdminNews({required this.id, required this.title, required this.imageUrl, required this.dateText, required this.body});
  final String id;
  final String title;
  final String imageUrl;
  final String dateText;
  final String body;
}

class AdminEvidence {
  const AdminEvidence({required this.id, required this.title, required this.date, required this.mediaUrls, required this.description});
  final String id;
  final String title;
  final String date;
  final List<String> mediaUrls;
  final String description;
}

class AdminModel {
  const AdminModel({required this.id, required this.title, required this.url, required this.active});
  final String id;
  final String title;
  final String url;
  final bool active;
}
