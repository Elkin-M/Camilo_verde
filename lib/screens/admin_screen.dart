import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:camilo_verde/services/admin_auth_service.dart';
import 'package:camilo_verde/services/admin_content_repository.dart';
import 'package:camilo_verde/services/drive_upload_service.dart';
import 'package:camilo_verde/config/backend_config.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _auth = AdminAuthService();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;
  User? _user;
  bool _superAdmin = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    try {
      await _auth.signIn(_email.text, _password.text);
      if (!await _auth.isActiveAdmin()) throw StateError('El usuario no es un administrador activo.');
      if (!mounted) return;
      setState(() { _user = _auth.currentUser; _superAdmin = false; });
      _superAdmin = await _auth.isSuperAdmin();
      if (mounted) setState(() {});
    } on FirebaseAuthException catch (error) {
      setState(() => _error = error.message ?? 'No se pudo iniciar sesión.');
    } catch (error) {
      setState(() => _error = error.toString().replaceFirst('Bad state: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    if (mounted) setState(() { _user = null; _superAdmin = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) return _buildLogin();
    return DefaultTabController(
      length: _superAdmin ? 3 : 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Panel administrador'),
          actions: [IconButton(onPressed: _logout, icon: const Icon(Icons.logout), tooltip: 'Cerrar sesión')],
          bottom: TabBar(tabs: [
            const Tab(text: 'Contenido'),
            const Tab(text: 'Inicio'),
            if (_superAdmin) const Tab(text: 'Usuarios'),
          ]),
        ),
        body: TabBarView(children: [
          const _ContentTab(),
          const _HomeTab(),
          if (_superAdmin) _UsersTab(currentUid: _user!.uid),
        ]),
      ),
    );
  }

  Widget _buildLogin() => Scaffold(
        appBar: AppBar(title: const Text('Administración')),
        body: Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.lock_outline, size: 52),
            const SizedBox(height: 20),
            TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Correo')),
            TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña')),
            if (_error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!, style: const TextStyle(color: Colors.red))),
            const SizedBox(height: 20),
            FilledButton(onPressed: _loading ? null : _login, child: Text(_loading ? 'Ingresando...' : 'Ingresar')),
          ])),
        )),
      );
}

class _ContentTab extends StatelessWidget {
  const _ContentTab();

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
        children: [
          const _SectionHeading(icon: Icons.newspaper, title: 'Noticias', subtitle: 'Noticias publicadas en la aplicación'),
          const _AddContentButton(collection: 'news'),
          const _FirestoreGroup(collection: 'news', emptyText: 'No hay noticias guardadas.'),
          const SizedBox(height: 24),
          const _SectionHeading(icon: Icons.event, title: 'Próximos eventos', subtitle: 'Eventos que se muestran en la aplicación'),
          const _AddContentButton(collection: 'events'),
          const _FirestoreGroup(collection: 'events', emptyText: 'No hay eventos guardados.'),
          const SizedBox(height: 24),
          const _SectionHeading(icon: Icons.photo_library, title: 'Evidencias', subtitle: 'Fotos y videos guardados en Drive'),
          const _AddEvidenceButton(),
          const _FirestoreGroup(collection: 'evidences', emptyText: 'No hay evidencias guardadas.'),
          const SizedBox(height: 24),
          const _SectionHeading(icon: Icons.view_in_ar, title: 'Modelos 3D', subtitle: 'Modelos activos disponibles para la app'),
          const _UploadButton(folder: 'model'),
          const _FirestoreGroup(collection: 'models', emptyText: 'No hay modelos 3D guardados.'),
        ],
      );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primaryContainer, child: Icon(icon)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          ])),
        ]),
      );
}

class _FirestoreGroup extends StatelessWidget {
  const _FirestoreGroup({required this.collection, required this.emptyText});
  final String collection;
  final String emptyText;

  String _value(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is List) return value.join(', ');
    return value?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection(collection).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return _GroupMessage(text: 'No se pudo leer esta sección.');
          if (!snapshot.hasData) return const Card(child: Padding(padding: EdgeInsets.all(18), child: LinearProgressIndicator()));
          if (snapshot.data!.docs.isEmpty) return _GroupMessage(text: emptyText);
          final docs = [...snapshot.data!.docs];
          docs.sort((a, b) => _dateValue(b.data()).compareTo(_dateValue(a.data())));
          return Column(children: docs.map((doc) {
            final data = doc.data();
            final title = _value(data, 'title').isNotEmpty ? _value(data, 'title') : _value(data, 'name');
            final mediaUrls = List<String>.from(data['mediaUrls'] ?? const []);
            final detail = collection == 'news'
                ? _value(data, 'body')
                : collection == 'events'
                    ? '${_value(data, 'dateText')} ${_value(data, 'time')}\n${_value(data, 'place')}'
                    : collection == 'evidences'
                        ? '${_value(data, 'date')}\n${_value(data, 'description')}\n${_value(data, 'mediaUrls')}'
                        : _value(data, 'url');
            return Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
              leading: collection == 'evidences' && mediaUrls.isNotEmpty
                  ? Image.network(mediaUrls.first, width: 58, height: 58, fit: BoxFit.cover, errorBuilder: (_, _, _) => const Icon(Icons.broken_image_outlined))
                  : null,
              title: Text(title.isEmpty ? doc.id : title, maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: Text(detail.isEmpty ? 'Sin información adicional' : detail, maxLines: 4, overflow: TextOverflow.ellipsis),
              isThreeLine: detail.isNotEmpty,
              trailing: IconButton(icon: const Icon(Icons.delete_outline), tooltip: 'Eliminar', onPressed: () async {
                final confirmed = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
                  title: const Text('Eliminar registro'),
                  content: Text('¿Quieres eliminar "$title"?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
                    FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Eliminar')),
                  ],
                ));
                if (confirmed != true || !context.mounted) return;
                showDialog<void>(context: context, barrierDismissible: false, builder: (_) => const _ProgressDialog(label: 'Eliminando...'));
                final fileIds = _fileIds(data);
                try {
                  await AdminContentRepository().delete(collection, doc.id, fileIds: fileIds);
                } finally {
                  if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
                }
              }),
            ));
          }).toList());
        },
      );

  DateTime _dateValue(Map<String, dynamic> data) {
    final value = '${data['date'] ?? data['dateText'] ?? data['fecha'] ?? ''}';
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return parsed;
    final parts = value.split(RegExp(r'[/.-]'));
    if (parts.length == 3) {
      final first = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final last = int.tryParse(parts[2]);
      if (first != null && month != null && last != null) {
        return first > 31 ? DateTime(first, month, last) : DateTime(last, month, first);
      }
    }
    return DateTime(2000);
  }

  List<String> _fileIds(Map<String, dynamic> data) {
    final ids = <String>{...List<String>.from(data['fileIds'] ?? const [])};
    final values = <dynamic>[
      data['mediaUrls'],
      data['imageUrls'],
      data['imagenes'],
      data['imageUrl'],
      data['url'],
    ];
    for (final value in values) {
      final urls = value is List ? value : [value];
      for (final url in urls) {
        final match = RegExp(r'(?:id=|/d/)([A-Za-z0-9_-]{10,})').firstMatch('$url');
        if (match != null) ids.add(match.group(1)!);
      }
    }
    return ids.toList();
  }
}

class _GroupMessage extends StatelessWidget {
  const _GroupMessage({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(18), child: Text(text)));
}

Future<void> _runWithProgress(BuildContext context, String label, Future<void> Function() action) async {
  showDialog<void>(context: context, barrierDismissible: false, builder: (_) => _ProgressDialog(label: label));
  try {
    await action();
  } finally {
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
  }
}

class _ProgressDialog extends StatelessWidget {
  const _ProgressDialog({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => AlertDialog(
        content: Row(children: [const SizedBox(width: 24, height: 24, child: CircularProgressIndicator()), const SizedBox(width: 18), Text(label)]),
      );
}

class _AddContentButton extends StatelessWidget {
  const _AddContentButton({required this.collection});
  final String collection;

  Future<void> _add(BuildContext context) async {
    final title = TextEditingController();
    final date = TextEditingController();
    final body = TextEditingController();
    PlatformFile? selectedImage;
    final saved = await showDialog<Map<String, dynamic>>(context: context, builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) => AlertDialog(
      title: Text(collection == 'news' ? 'Añadir noticia' : 'Añadir evento'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: title, decoration: const InputDecoration(labelText: 'Título')),
        TextField(
          controller: date,
          readOnly: true,
          onTap: () async {
            final picked = await showDatePicker(context: dialogContext, firstDate: DateTime(2020), lastDate: DateTime(2100), initialDate: DateTime.now());
            if (picked != null) date.text = '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
          },
          decoration: const InputDecoration(labelText: 'Fecha', suffixIcon: Icon(Icons.calendar_today_outlined)),
        ),
        TextField(controller: body, maxLines: 4, decoration: InputDecoration(labelText: collection == 'news' ? 'Contenido' : 'Hora, lugar e indicaciones')),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () async {
            final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
            if (result != null && result.files.single.bytes != null) setDialogState(() => selectedImage = result.files.single);
          },
          icon: const Icon(Icons.image_outlined),
          label: Text(selectedImage == null ? 'Seleccionar imagen' : selectedImage!.name),
        ),
        if (selectedImage?.bytes != null) Padding(padding: const EdgeInsets.only(top: 10), child: Image.memory(selectedImage!.bytes!, height: 150, fit: BoxFit.contain)),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(dialogContext, {'save': true, 'file': selectedImage}), child: const Text('Guardar')),
      ],
    )));
    if (saved?['save'] == true && title.text.trim().isNotEmpty) {
      if (!context.mounted) return;
      String imageUrl = '';
      final fileIds = <String>[];
      final file = saved?['file'] as PlatformFile?;
      await _runWithProgress(context, 'Guardando...', () async {
        if (file?.bytes != null) {
          final upload = await DriveUploadService().upload(bytes: file!.bytes!, name: file.name, contentType: 'image/${file.extension ?? 'jpeg'}', folder: 'evidence');
          imageUrl = upload.url;
          fileIds.add(upload.fileId);
        }
        final data = collection == 'news'
            ? {'title': title.text.trim(), 'dateText': date.text.trim(), 'body': body.text.trim(), 'imageUrl': imageUrl, 'fileIds': fileIds}
            : {'title': title.text.trim(), 'date': date.text.trim(), 'dateText': date.text.trim(), 'time': body.text.trim(), 'place': '', 'instructions': body.text.trim(), 'imageUrl': imageUrl, 'fileIds': fileIds, 'icon': 'event'};
        await AdminContentRepository().create(collection, data);
      });
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guardado en Firebase')));
    }
    title.dispose();
    date.dispose();
    body.dispose();
  }

  @override
  Widget build(BuildContext context) => Align(alignment: Alignment.centerRight, child: OutlinedButton.icon(
        onPressed: () => _add(context),
        icon: const Icon(Icons.add),
        label: Text(collection == 'news' ? 'Añadir noticia' : 'Añadir evento'),
      ));
}

class _UploadButton extends StatelessWidget {
  const _UploadButton({required this.folder});
  final String folder;

  Future<void> _pick(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || result.files.single.bytes == null) return;
    if (!context.mounted) return;
    final file = result.files.single;
    await _runWithProgress(context, 'Subiendo modelo...', () async {
      final upload = await DriveUploadService().upload(bytes: file.bytes!, name: file.name, contentType: 'application/octet-stream', folder: folder);
      await AdminContentRepository().create('models', {'title': file.name, 'url': upload.url, 'fileIds': [upload.fileId], 'active': true});
    });
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Modelo guardado en Firebase')));
  }

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerRight,
        child: OutlinedButton.icon(
          onPressed: () => _pick(context),
          icon: const Icon(Icons.upload_file),
          label: const Text('Añadir modelo 3D'),
        ),
      );
}

class _AddEvidenceButton extends StatefulWidget {
  const _AddEvidenceButton();
  @override
  State<_AddEvidenceButton> createState() => _AddEvidenceButtonState();
}

class _AddEvidenceButtonState extends State<_AddEvidenceButton> {
  PlatformFile? _file;
  final _title = TextEditingController();
  final _date = TextEditingController();
  final _description = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _date.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result != null && result.files.single.bytes != null) setState(() => _file = result.files.single);
  }

  Future<void> _save() async {
    if (_file?.bytes == null || _title.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      final upload = await DriveUploadService().upload(bytes: _file!.bytes!, name: _file!.name, contentType: 'image/${_file!.extension ?? 'jpeg'}', folder: 'evidence');
      try {
        await AdminContentRepository().create('evidences', {'title': _title.text.trim(), 'date': _date.text.trim(), 'mediaUrls': [upload.url], 'fileIds': [upload.fileId], 'description': _description.text.trim()});
      } catch (_) {
        await DriveUploadService().trash(upload.fileId);
        rethrow;
      }
      if (mounted) {
        setState(() {
          _file = null;
          _error = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Evidencia guardada en Firebase y Drive')));
      }
    } catch (error) {
      final message = error.toString().replaceFirst('Bad state: ', '');
      if (mounted) {
        setState(() => _error = message);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        TextField(controller: _title, decoration: const InputDecoration(labelText: 'Título de la evidencia')),
        TextField(
          controller: _date,
          readOnly: true,
          onTap: () async {
            final picked = await showDatePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime(2100), initialDate: DateTime.now());
            if (picked != null) _date.text = '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
          },
          decoration: const InputDecoration(labelText: 'Fecha', suffixIcon: Icon(Icons.calendar_today_outlined)),
        ),
        TextField(controller: _description, maxLines: 2, decoration: const InputDecoration(labelText: 'Descripción')),
        const SizedBox(height: 12),
        OutlinedButton.icon(onPressed: _selectImage, icon: const Icon(Icons.image_outlined), label: Text(_file == null ? 'Seleccionar imagen' : _file!.name)),
        if (_file?.bytes != null) Padding(padding: const EdgeInsets.only(top: 12), child: Image.memory(_file!.bytes!, height: 180, fit: BoxFit.contain)),
        if (_error != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(_error!, style: const TextStyle(color: Colors.red))),
        const SizedBox(height: 12),
        FilledButton.icon(onPressed: _saving ? null : _save, icon: const Icon(Icons.cloud_upload_outlined), label: Text(_saving ? 'Guardando...' : 'Guardar evidencia')),
      ])));
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();
  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final _controller = TextEditingController();
  final _carouselTitle = TextEditingController();
  final _carouselDescription = TextEditingController();
  String _carouselImageUrl = '';
  bool _savingHome = false;

  @override
  void initState() {
    super.initState();
    _loadVideo();
    _loadCarousel();
  }

  Future<void> _loadVideo() async {
    final snapshot = await FirebaseFirestore.instance.collection('settings').doc('home').get();
    if (mounted) _controller.text = snapshot.data()?['videoUrl']?.toString() ?? '';
  }

  Future<void> _loadCarousel() async {
    final data = await FirebaseFirestore.instance.collection('settings').doc('home').get();
    if (!mounted) return;
    final values = data.data() ?? {};
    setState(() {
      _carouselImageUrl = values['carouselImageUrl']?.toString() ?? '';
      _carouselTitle.text = values['carouselTitle']?.toString() ?? '';
      _carouselDescription.text = values['carouselDescription']?.toString() ?? '';
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _carouselTitle.dispose();
    _carouselDescription.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(20, 24, 20, 32), children: [
        const _SectionHeading(icon: Icons.view_carousel_outlined, title: 'Carrusel de Inicio', subtitle: 'Selecciona la imagen y cambia el texto principal'),
        Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(stream: FirebaseFirestore.instance.collection('evidences').snapshots(), builder: (context, snapshot) {
            final choices = snapshot.data?.docs ?? const [];
            return DropdownButtonFormField<String>(initialValue: _carouselImageUrl.isEmpty ? null : _carouselImageUrl, isExpanded: true, decoration: const InputDecoration(labelText: 'Imagen del carrusel'), items: choices.expand((doc) {
              final data = doc.data();
              final values = data['mediaUrls'] ?? data['imageUrls'] ?? data['imagenes'] ?? const [];
              final urls = values is List ? List<String>.from(values) : [values.toString()];
              return urls.where((url) => url.isNotEmpty).map((url) => DropdownMenuItem(value: url, child: Text(url, overflow: TextOverflow.ellipsis)));
            }).toList(), onChanged: (value) => setState(() => _carouselImageUrl = value ?? ''));
          }),
          if (_carouselImageUrl.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 12), child: Image.network(_carouselImageUrl, height: 150, fit: BoxFit.cover)),
          TextField(controller: _carouselTitle, decoration: const InputDecoration(labelText: 'Título escrito')),
          TextField(controller: _carouselDescription, maxLines: 3, decoration: const InputDecoration(labelText: 'Texto escrito')),
          const SizedBox(height: 14),
          FilledButton.icon(onPressed: _savingHome ? null : () async {
            setState(() => _savingHome = true);
            try {
              await AdminContentRepository().setHomeCarousel(imageUrl: _carouselImageUrl, title: _carouselTitle.text.trim(), description: _carouselDescription.text.trim());
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Carrusel actualizado')));
            } finally { if (mounted) setState(() => _savingHome = false); }
          }, icon: _savingHome ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_outlined), label: Text(_savingHome ? 'Guardando...' : 'Guardar carrusel')),
        ]))),
        const SizedBox(height: 28),
        const _SectionHeading(icon: Icons.play_circle_outline, title: 'Video del carrusel', subtitle: 'Enlace que aparece en la sección de avances'),
        Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TextField(controller: _controller, keyboardType: TextInputType.url, decoration: const InputDecoration(labelText: 'Enlace del video', hintText: 'https://...')),
          const SizedBox(height: 14),
          FilledButton.icon(onPressed: () async {
            await AdminContentRepository().setHomeVideo(_controller.text.trim());
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Video actualizado')));
          }, icon: const Icon(Icons.save_outlined), label: const Text('Guardar enlace')),
        ]))),
        const SizedBox(height: 28),
        const _SectionHeading(icon: Icons.info_outline, title: 'Contenido conectado', subtitle: 'Los cambios se leen directamente desde Firestore'),
        Card(child: ListTile(leading: const Icon(Icons.cloud_done_outlined), title: const Text('Firebase conectado'), subtitle: Text('Proyecto: ${BackendConfig.projectId}\nLas noticias, eventos, evidencias y modelos aparecen en la pestaña Contenido.'))),
      ]);
}

class _UsersTab extends StatelessWidget {
  const _UsersTab({required this.currentUid});
  final String currentUid;
  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(stream: AdminAuthService().users(), builder: (context, snapshot) {
    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
    return ListView(children: snapshot.data!.docs.map((doc) { final data = doc.data(); final active = data['active'] == true; return SwitchListTile(title: Text(data['email'] ?? doc.id), subtitle: Text(data['role'] ?? 'admin'), value: active, onChanged: doc.id == currentUid ? null : (value) => AdminAuthService().updateUser(doc.id, active: value)); }).toList());
  });
}
