import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:http/http.dart' as http;

// -- Función para descargar una imagen desde una URL y guardarla en la galería --
Future<void> descargarImagen(BuildContext context, String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    final tempDir = await getTemporaryDirectory();
    final path =
        '${tempDir.path}/evidencia_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File(path);
    await file.writeAsBytes(response.bodyBytes);
    await Gal.putImage(file.path);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Imagen guardada en la galería!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    debugPrint("Error al descargar imagen: $e");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar la imagen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// -- Función para abrir el enlace del video para descarga en navegador --
Future<void> descargarVideo(BuildContext context, String url) async {
  final Uri uri = Uri.parse(url);
  try {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir el enlace');
    }
  } catch (e) {
    debugPrint("Error al abrir video para descarga: $e");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir el enlace del video'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// -- Visor para reproducir videos o ver imágenes --
class VisorMultimedia extends StatefulWidget {
  final String path;
  const VisorMultimedia({super.key, required this.path});

  @override
  State<VisorMultimedia> createState() => _VisorMultimediaState();
}

class _VisorMultimediaState extends State<VisorMultimedia> {
  VideoPlayerController? _controller;

  bool get esVideo =>
      widget.path.toLowerCase().contains('.mp4') ||
      widget.path.toLowerCase().contains('.mov') ||
      widget.path.contains('video/upload');

  @override
  void initState() {
    super.initState();
    if (esVideo) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.path))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _controller!.play();
          }
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (esVideo) {
      return _controller != null && _controller!.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  VideoPlayer(_controller!),
                  _buildControlesVideo(),
                  VideoProgressIndicator(_controller!, allowScrubbing: true),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator(color: Colors.green));
    }

    return InteractiveViewer(
      child: Image.network(
        widget.path,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image, color: Colors.grey, size: 50),
        ),
      ),
    );
  }

  Widget _buildControlesVideo() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _controller!.value.isPlaying
              ? _controller!.pause()
              : _controller!.play();
        });
      },
      child: Container(
        color: Colors.transparent,
        child: Center(
          child: Icon(
            _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white.withValues(alpha: 0.7),
            size: 70,
          ),
        ),
      ),
    );
  }
}

// -- Miniatura de video generada dinámicamente --
class MiniaturaVideo extends StatefulWidget {
  final String videoUrl;
  final BoxFit fit;

  const MiniaturaVideo({
    super.key,
    required this.videoUrl,
    this.fit = BoxFit.cover,
  });

  @override
  State<MiniaturaVideo> createState() => _MiniaturaVideoState();
}

class _MiniaturaVideoState extends State<MiniaturaVideo> {
  Uint8List? _bytes;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _generarMiniatura();
  }

  Future<void> _generarMiniatura() async {
    try {
      final bytes = await VideoThumbnail.thumbnailData(
        video: widget.videoUrl,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 300,
        quality: 75,
      );
      if (mounted) {
        setState(() {
          _bytes = bytes;
        });
      }
    } catch (e) {
      debugPrint('Error generando miniatura: $e');
      if (mounted) {
        setState(() {
          _error = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bytes != null) {
      return Image.memory(
        _bytes!,
        fit: widget.fit,
        alignment: Alignment.topCenter,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, color: Colors.grey),
      );
    } else if (_error) {
      return const Icon(
        Icons.play_circle_outline,
        color: Colors.grey,
        size: 50,
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green),
      );
    }
  }
}

// -- Pantalla para ver y hacer zoom a imágenes en pantalla completa --
class ZoomPage extends StatelessWidget {
  final String assetPath;

  const ZoomPage({super.key, required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SizedBox.expand(
        child: InteractiveViewer(
          clipBehavior: Clip.none,
          panEnabled: true,
          minScale: 1.0,
          maxScale: 5.0,
          child: Center(
            child: Image.network(
              assetPath,
              fit: BoxFit.contain,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, color: Colors.white, size: 50),
            ),
          ),
        ),
      ),
    );
  }
}
