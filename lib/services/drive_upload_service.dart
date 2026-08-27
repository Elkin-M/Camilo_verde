import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:camilo_verde/config/backend_config.dart';

class DriveUploadResult {
  const DriveUploadResult({required this.url, required this.fileId, required this.mimeType});
  final String url;
  final String fileId;
  final String mimeType;
}

class DriveUploadService {
  Future<DriveUploadResult> upload({required List<int> bytes, required String name, required String contentType, required String folder}) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) throw StateError('La sesión de administrador expiró.');
    final response = await http.post(
      Uri.parse(BackendConfig.driveUploadEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'idToken': token,
        'folder': folder,
        'file': {'name': name, 'contentType': contentType, 'base64': base64Encode(bytes)},
      }),
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400 || data['error'] != null) {
      throw StateError(data['error']?.toString() ?? 'No se pudo subir el archivo.');
    }
    return DriveUploadResult(url: data['url'], fileId: data['fileId'], mimeType: data['mimeType']);
  }

  Future<void> trash(String fileId) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) throw StateError('La sesión de administrador expiró.');
    final response = await http.post(
      Uri.parse(BackendConfig.driveUploadEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idToken': token, 'action': 'trash', 'fileId': fileId}),
    );
    if (response.statusCode >= 400 || (jsonDecode(response.body) as Map)['error'] != null) {
      throw StateError('No se pudo enviar el archivo a la papelera.');
    }
  }
}
