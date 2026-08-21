import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:camilo_verde/config/constants.dart';
import 'package:camilo_verde/widgets/visor_multimedia.dart';

class SeccionGaleria extends StatefulWidget {
  const SeccionGaleria({super.key});

  @override
  State<SeccionGaleria> createState() => _SeccionGaleriaState();
}

class _SeccionGaleriaState extends State<SeccionGaleria> {
  List<Map<String, dynamic>> evidencias = [];
  bool cargando = true;
  bool _ascendente = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosDeSheets();
  }

  Future<void> _cargarDatosDeSheets() async {
    final url = Uri.parse(AppConstants.sheetGaleriaUrl);

    try {
      final respuesta = await http.get(url);
      if (respuesta.statusCode == 200) {
        String tsvTexto = utf8.decode(respuesta.bodyBytes);
        List<String> lineas = tsvTexto.split('\n');
        List<Map<String, dynamic>> temporal = [];

        for (int i = 1; i < lineas.length; i++) {
          if (lineas[i].trim().isEmpty) continue;
          List<String> celdas = lineas[i].split('\t');

          if (celdas.length >= 4) {
            temporal.add({
              'nombre': celdas[0].trim(),
              'fecha': celdas[1].trim(),
              'imagenes': celdas[2].trim().split(';'),
              'desc': celdas[3].trim(),
            });
          }
        }

        if (mounted) {
          setState(() {
            evidencias = temporal;
            cargando = false;
            _ordenarAlCargar();
          });
        }
      }
    } catch (e) {
      debugPrint("Error conectando a Sheets: $e");
      if (mounted) setState(() => cargando = false);
    }
  }

  void _ordenarAlCargar() {
    evidencias.sort(
      (a, b) => _parseFecha(b['fecha']).compareTo(_parseFecha(a['fecha'])),
    );
  }

  void _ordenarGaleria() {
    setState(() {
      _ascendente = !_ascendente;
      evidencias.sort((a, b) {
        DateTime fechaA = _parseFecha(a['fecha']);
        DateTime fechaB = _parseFecha(b['fecha']);
        return _ascendente
            ? fechaA.compareTo(fechaB)
            : fechaB.compareTo(fechaA);
      });
    });
  }

  DateTime _parseFecha(dynamic fecha) {
    if (fecha == null) return DateTime(2000);
    if (fecha is DateTime) return fecha;

    try {
      String fechaStr = fecha.toString();
      String separador = fechaStr.contains('-') ? '-' : '/';
      List<String> partes = fechaStr.split(separador);
      return DateTime(
        int.parse(partes[0]),
        int.parse(partes[1]),
        int.parse(partes[2]),
      );
    } catch (e) {
      debugPrint("Error parseando fecha: $e");
      return DateTime(2000);
    }
  }

  void _mostrarDetalle(BuildContext context, Map<String, dynamic> data) {
    List<String> archivos = List<String>.from(data['imagenes']);
    final String url = data['imagenes'][0];
    final PageController detalleController = PageController();
    int paginaActual = 0;

    bool esVideo =
        url.toLowerCase().contains('.mp4') ||
        url.toLowerCase().contains('.mov') ||
        url.contains('video/upload');

    if (esVideo) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.green[800],
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: const Text("Video", style: TextStyle(color: Colors.white)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () => descargarVideo(context, url),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Colors.black,
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.35,
                    child: Center(child: VisorMultimedia(path: url)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              data['fecha'] ?? "",
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const Icon(
                              Icons.video_library,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          data['nombre'] ?? "",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const Divider(height: 30, thickness: 1),
                        const Text(
                          "Descripción:",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data['desc'] ?? "",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => StatefulBuilder(
          builder: (context, setModalState) {
            return FractionallySizedBox(
              heightFactor: 0.9,
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.4,
                        ),
                        child: PageView.builder(
                          controller: detalleController,
                          itemCount: archivos.length,
                          onPageChanged: (index) =>
                              setModalState(() => paginaActual = index),
                          itemBuilder: (context, index) {
                            return Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ZoomPage(
                                            assetPath: archivos[index],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(17),
                                        child: Image.network(
                                          archivos[index],
                                          fit: BoxFit.scaleDown,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.broken_image,
                                                    size: 50,
                                                    color: Colors.grey,
                                                  ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Positioned(
                                    top: 22,
                                    right: 22,
                                    child: Icon(
                                      Icons.zoom_in,
                                      color: Colors.black54,
                                      size: 28,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      if (paginaActual > 0)
                        Positioned(
                          left: 10,
                          child: _buildBotonNavegacion(
                            icon: Icons.arrow_back_ios_new,
                            onPressed: () => detalleController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            ),
                          ),
                        ),
                      if (paginaActual < archivos.length - 1)
                        Positioned(
                          right: 10,
                          child: _buildBotonNavegacion(
                            icon: Icons.arrow_forward_ios,
                            onPressed: () => detalleController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['nombre'],
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            data['fecha'] ?? "",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(height: 15),
                          Text(
                            data['desc'],
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                String urlADescargar = archivos[paginaActual];
                                descargarImagen(context, urlADescargar);
                              },
                              icon: const Icon(Icons.cloud_download),
                              label: const Text("Descargar Imagen"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[800],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
  }

  Widget _buildBotonNavegacion({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black26,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.green),
      );
    }

    if (evidencias.isEmpty) {
      return const Center(child: Text("No hay evidencias registradas todavía"));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Evidencias",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: _ordenarGaleria,
                icon: Icon(
                  _ascendente ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 18,
                  color: Colors.green[800],
                ),
                label: Text(
                  _ascendente ? "Más antiguos" : "Más nuevos",
                  style: TextStyle(color: Colors.green[800]),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: Colors.green,
            onRefresh: _cargarDatosDeSheets,
            child: GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.8,
              ),
              itemCount: evidencias.length,
              itemBuilder: (context, index) {
                final Map<String, dynamic> evidencia = evidencias[index];
                final String primeraImagen = evidencia['imagenes'][0];
                final bool esVideo =
                    primeraImagen.toLowerCase().contains('.mp4') ||
                    primeraImagen.toLowerCase().contains('.mov') ||
                    primeraImagen.contains('video/upload');

                return Card(
                  elevation: 3,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () => _mostrarDetalle(context, evidencia),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: esVideo
                                      ? MiniaturaVideo(
                                          videoUrl: primeraImagen,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.network(
                                          primeraImagen,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.broken_image,
                                                    color: Colors.grey,
                                                  ),
                                          loadingBuilder:
                                              (
                                                context,
                                                child,
                                                loadingProgress,
                                              ) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.green,
                                                      ),
                                                );
                                              },
                                        ),
                                ),
                                if (esVideo)
                                  const Center(
                                    child: Icon(
                                      Icons.play_circle_fill,
                                      color: Colors.white70,
                                      size: 36,
                                    ),
                                  ),
                                if (evidencia['imagenes'].length > 1)
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Icon(
                                        Icons.collections,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6.0),
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  evidencia['nombre'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  evidencia['fecha'] ?? "",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
