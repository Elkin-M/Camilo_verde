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
  Future<http.Response> _postJson(Map<String, dynamic> payload) async {
    final request = http.Request('POST', Uri.parse(BackendConfig.driveUploadEndpoint))
      ..followRedirects = false
      ..headers['Content-Type'] = 'text/plain;charset=utf-8'
      ..body = jsonEncode(payload);
    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode < 300 || response.statusCode >= 400) return response;

    final location = response.headers['location'];
    if (location == null || location.isEmpty) {
      throw StateError('Apps Script devolvió una respuesta vacía (${response.statusCode}) sin dirección de redirección.');
    }
    var redirected = await http.get(Uri.parse(location));
    for (var attempt = 0; attempt < 4 && redirected.statusCode >= 300 && redirected.statusCode < 400; attempt++) {
      final next = redirected.headers['location'];
      if (next == null || next.isEmpty) break;
      redirected = await http.get(Uri.parse(next));
    }
    return redirected;
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.body.trim().isEmpty) {
      throw StateError('Apps Script devolvió una respuesta vacía (${response.statusCode}).');
    }
    if (response.body.trimLeft().startsWith('<')) {
      throw StateError('Apps Script devolvió HTML (${response.statusCode}). Verifica que la implementación sea una aplicación web con acceso para cualquier usuario.');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw StateError('Apps Script devolvió una respuesta inválida.');
    }
    return decoded;
  }

  Future<DriveUploadResult> upload({required List<int> bytes, required String name, required String contentType, required String folder}) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) throw StateError('La sesión de administrador expiró.');
    final response = await _postJson({
        'idToken': token,
        'folder': folder,
        'file': {'name': name, 'contentType': contentType, 'base64': base64Encode(bytes)},
      });
    final data = _decodeResponse(response);
    if (response.statusCode >= 400 || data['error'] != null) {
      throw StateError(data['error']?.toString() ?? 'No se pudo subir el archivo.');
    }
    return DriveUploadResult(url: data['url'], fileId: data['fileId'], mimeType: data['mimeType']);
  }

  Future<void> trash(String fileId) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) throw StateError('La sesión de administrador expiró.');
    final response = await _postJson({'idToken': token, 'action': 'trash', 'fileId': fileId});
    final data = _decodeResponse(response);
    if (response.statusCode >= 400 || data['error'] != null) {
      throw StateError('No se pudo enviar el archivo a la papelera.');
    }
  }
}
