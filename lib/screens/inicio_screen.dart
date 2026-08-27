import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:camilo_verde/config/constants.dart';
import 'package:camilo_verde/services/public_content_repository.dart';
import 'package:camilo_verde/widgets/visor_multimedia.dart';

class SeccionInicio extends StatefulWidget {
  const SeccionInicio({super.key});

  @override
  State<SeccionInicio> createState() => _SeccionInicioState();
}

class _SeccionInicioState extends State<SeccionInicio> {
  List<Map<String, dynamic>> noticiasDinamicas = [];
  List<Map<String, dynamic>> fotosRecientes = [];
  List<Map<String, dynamic>> eventosProximos = [];

  bool cargandoNoticias = true;
  bool cargandoFotos = true;
  bool cargandoEventos = true;
  String _videoAvancesUrl = AppConstants.videoAvancesUrl;
  String _carouselImageUrl = '';
  String _carouselTitle = 'Proyecto Ambiental PRAE Camilo Verde';
  String _carouselDescription = 'Descubre nuestras iniciativas ecológicas y los avances recientes de nuestra comunidad.';

  int _indiceCarrusel = 0;
  final PageController _pageController = PageController();
  Timer? _temporizadorCarrusel;

  @override
  void initState() {
    super.initState();
    _cargarTodo();
    _temporizadorCarrusel = Timer.periodic(
      const Duration(seconds: 7),
      (_) => _avanzarCarrusel(),
    );
  }

  Future<void> _cargarVideoDeFirestore() async {
    try {
      final url = await PublicContentRepository().getVideoUrl();
      if (mounted && url != null && url.isNotEmpty) {
        setState(() => _videoAvancesUrl = url);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _temporizadorCarrusel?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _avanzarCarrusel() {
    if (!mounted || !_pageController.hasClients) return;

    final totalSlides = fotosRecientes.length + 1;
    if (totalSlides <= 1) return;

    final siguiente = (_indiceCarrusel + 1) % totalSlides;
    _pageController.animateToPage(
      siguiente,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _cargarTodo() async {
    await Future.wait([
      _cargarNoticiasDeSheets(),
      _cargarFotosRecientesDeSheets(),
      _cargarEventosProximos(),
      _cargarVideoDeFirestore(),
      _cargarCarruselDeFirestore(),
    ]);
  }

  Future<void> _cargarCarruselDeFirestore() async {
    try {
      final carousel = await PublicContentRepository().getHomeCarousel();
      if (!mounted) return;
      setState(() {
        _carouselImageUrl = carousel['imageUrl'] ?? '';
        _carouselTitle = carousel['title'] ?? _carouselTitle;
        _carouselDescription = carousel['description'] ?? _carouselDescription;
      });
    } catch (_) {}
  }

  Future<void> _cargarNoticiasDeSheets() async {
    final url = Uri.parse(AppConstants.sheetNoticiasUrl);
    try {
      final firestoreNews = await PublicContentRepository().getNews();
      if (firestoreNews.isNotEmpty) {
        if (mounted) {
          setState(() {
            noticiasDinamicas = firestoreNews.map((news) => {
              'titulo': news.title,
              'imagen': news.imageUrl,
              'fechaTexto': news.dateText,
              'contenido': news.body,
            }).toList();
            cargandoNoticias = false;
          });
        }
        return;
      }
      final respuesta = await http.get(url);
      if (respuesta.statusCode == 200) {
        final lineas = utf8.decode(respuesta.bodyBytes).split('\n');
        final temporal = <Map<String, dynamic>>[];
        for (int i = 1; i < lineas.length; i++) {
          if (lineas[i].trim().isEmpty) continue;
          final celdas = lineas[i].split('\t');
          if (celdas.length >= 4) {
            temporal.add({
              'titulo': celdas[0].trim(),
              'imagen': celdas[1].trim(),
              'fechaTexto': celdas[2].trim(),
              'contenido': celdas[3].trim(),
            });
          }
        }
        if (mounted) {
          setState(() {
            noticiasDinamicas = temporal;
            cargandoNoticias = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error cargando noticias: $e');
      if (mounted) setState(() => cargandoNoticias = false);
    }
  }

  Future<void> _cargarFotosRecientesDeSheets() async {
    final url = Uri.parse(AppConstants.sheetGaleriaUrl);
    try {
      final firestoreEvidences = await PublicContentRepository().getEvidences();
      final evidencias = <Map<String, dynamic>>[];
      try {
        final respuesta = await http.get(url);
        if (respuesta.statusCode == 200) {
        final lineas = utf8.decode(respuesta.bodyBytes).split('\n');
        for (int i = 1; i < lineas.length; i++) {
          if (lineas[i].trim().isEmpty) continue;
          final celdas = lineas[i].split('\t');
          if (celdas.length >= 4) {
            evidencias.add({
              'nombre': celdas[0].trim(),
              'fecha': celdas[1].trim(),
              'imagenes': celdas[2].trim().split(';'),
              'desc': celdas[3].trim(),
            });
          }
        }
        }
      } catch (_) {}
        evidencias.addAll(firestoreEvidences.map((evidence) => {
          'nombre': evidence.title,
          'fecha': evidence.date,
          'imagenes': evidence.mediaUrls,
          'desc': evidence.description,
        }));
        evidencias.sort((a, b) {
          final fechaA = DateTime.tryParse(a['fecha']) ?? DateTime(2000);
          final fechaB = DateTime.tryParse(b['fecha']) ?? DateTime(2000);
          return fechaB.compareTo(fechaA);
        });
      if (mounted) {
        setState(() {
          fotosRecientes = evidencias.take(5).toList();
          cargandoFotos = false;
        });
      }
    } catch (e) {
      debugPrint('Error cargando fotos de bienvenida: $e');
      if (mounted) setState(() => cargandoFotos = false);
    }
  }

  Future<void> _cargarEventosProximos() async {
    final url = Uri.parse(AppConstants.sheetEventosUrl);
    try {
      final respuesta = await http.get(url);
      if (respuesta.statusCode == 200) {
        final lineas = utf8.decode(respuesta.bodyBytes).split('\n');
        final eventos = <Map<String, dynamic>>[];
        final ahora = DateTime.now();
        final hoyInicio = DateTime(ahora.year, ahora.month, ahora.day);
        for (int i = 1; i < lineas.length; i++) {
          if (lineas[i].trim().isEmpty) continue;
          final celdas = lineas[i].split('\t');
          if (celdas.length < 2) continue;
          final fecha = DateTime.tryParse(celdas[1].trim()) ?? DateTime(2000);
          if (fecha.isBefore(hoyInicio)) continue;
          eventos.add({
            'titulo': celdas[0].trim(),
            'fecha': fecha,
            'fechaTexto': celdas.length > 2 ? celdas[2].trim() : '',
            'horaTexto': celdas.length > 3 ? celdas[3].trim() : '',
            'lugar': celdas.length > 4 ? celdas[4].trim() : '',
            'imagen': celdas.length > 5 ? celdas[5].trim() : '',
            'indicaciones': celdas.length > 6 ? celdas[6].trim() : '',
            'icono': celdas.length > 7 ? celdas[7].trim() : 'event',
          });
        }
        if (mounted) {
          eventos.sort((a, b) => a['fecha'].compareTo(b['fecha']));
          setState(() {
            eventosProximos = eventos.take(2).toList();
            cargandoEventos = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error en Inicio - Eventos: $e');
      if (mounted) setState(() => cargandoEventos = false);
    }
  }

  Future<void> _abrirVideo(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('No se pudo abrir $url');
    }
  }

  List<Widget> _obtenerSlidesCarrusel() {
    final slides = <Widget>[
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32),
          image: _carouselImageUrl.isEmpty ? null : DecorationImage(image: NetworkImage(_carouselImageUrl), fit: BoxFit.cover, opacity: 0.35),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🌱 ¡Bienvenidos!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _carouselTitle,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _carouselDescription,
              style: TextStyle(color: Colors.white70, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _abrirVideo(_videoAvancesUrl),
                icon: const Icon(Icons.play_circle_fill, color: Colors.green),
                label: const Text('Ver Últimos Avances'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ];

    for (final evidencia in fotosRecientes) {
      final imagenes = evidencia['imagenes'];
      if (imagenes is! List || imagenes.isEmpty) continue;
      var urlImagen = imagenes[0].toString();
      if (urlImagen.toLowerCase().contains('.mp4') ||
          urlImagen.toLowerCase().contains('.mov') ||
          urlImagen.contains('video/upload')) {
        urlImagen = urlImagen
            .replaceAll('.mp4', '.jpg')
            .replaceAll('.mov', '.jpg');
      }
      slides.add(
        ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                urlImagen,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 40),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              Positioned(
                bottom: 15,
                left: 15,
                right: 15,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      evidencia['nombre'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      evidencia['fecha'] ?? '',
                      style: const TextStyle(
                        color: Colors.lightGreenAccent,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return slides;
  }

  @override
  Widget build(BuildContext context) {
    if (cargandoNoticias || cargandoFotos) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.green),
      );
    }
    final slides = _obtenerSlidesCarrusel();
    final contenido = <Widget>[
      SizedBox(
        height: 230,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: slides.length,
                onPageChanged: (index) =>
                    setState(() => _indiceCarrusel = index),
                itemBuilder: (_, index) => slides[index],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                slides.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 6,
                  width: _indiceCarrusel == index ? 18 : 6,
                  decoration: BoxDecoration(
                    color: _indiceCarrusel == index
                        ? Colors.green[800]
                        : Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 25),
      _buildSeccionTitulo('Bienvenido a Camilo Verde'),
      const SizedBox(height: 12),
      _buildSeccionTitulo('Multimedia reciente'),
      const SizedBox(height: 10),
      _buildMultimediaReciente(),
      const SizedBox(height: 25),
      _buildSeccionTitulo('Últimas noticias Camilistas'),
      const SizedBox(height: 10),
      if (noticiasDinamicas.isEmpty)
        const Text('No hay noticias cargadas hoy')
      else
        _buildCardNoticia(noticiasDinamicas.first),
      const SizedBox(height: 25),
      _buildSeccionTitulo('Próximos Eventos'),
      const SizedBox(height: 10),
      if (eventosProximos.isEmpty)
        const Text('No hay eventos programados próximamente')
      else
        ...eventosProximos.map(
          (evento) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              title: Text(
                evento['titulo'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${evento['fechaTexto']} - ${evento['horaTexto']}',
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () => _mostrarDetalleEvento(context, evento),
            ),
          ),
        ),
      const SizedBox(height: 20),
    ];
    return RefreshIndicator(
      onRefresh: _cargarTodo,
      color: Colors.green,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        children: contenido,
      ),
    );
  }

  Widget _buildSeccionTitulo(String titulo) => Text(
    titulo,
    style: GoogleFonts.unbounded(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.green[800],
    ),
  );

  Widget _buildMultimediaReciente() {
    if (fotosRecientes.isEmpty) {
      return const Text('No hay multimedia reciente');
    }

    final evidencia = fotosRecientes.first;
    final imagenes = evidencia['imagenes'];
    if (imagenes is! List || imagenes.isEmpty) {
      return const Text('No hay multimedia reciente');
    }

    final primeraImagen = imagenes.first.toString();
    final esVideo =
        primeraImagen.toLowerCase().contains('.mp4') ||
        primeraImagen.toLowerCase().contains('.mov') ||
        primeraImagen.contains('video/upload');

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => _mostrarDetalleMultimedia(context, evidencia),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (esVideo)
              SizedBox(
                height: 280,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MiniaturaVideo(
                      videoUrl: primeraImagen,
                      fit: BoxFit.contain,
                    ),
                    const Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        color: Colors.white70,
                        size: 48,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                color: Colors.grey[100],
                child: Image.network(
                  primeraImagen,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (_, error, stackTrace) => const SizedBox(
                    height: 180,
                    child: Center(child: Icon(Icons.broken_image, size: 40)),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Última evidencia subida',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Explora esta y todas las más recientes evidencias de nuestro proyecto ambiental en la sección Galería.',
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDetalleMultimedia(
    BuildContext context,
    Map<String, dynamic> evidencia,
  ) {
    _mostrarDetalleGaleria(context, evidencia);
  }

  void _mostrarDetalleGaleria(BuildContext context, Map<String, dynamic> data) {
    final archivos = List<String>.from(data['imagenes']);
    final url = data['imagenes'][0].toString();
    final detalleController = PageController();
    int paginaActual = 0;
    final esVideo =
        url.toLowerCase().contains('.mp4') ||
        url.toLowerCase().contains('.mov') ||
        url.contains('video/upload');

    if (esVideo) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.green[800],
              iconTheme: const IconThemeData(color: Colors.white),
              title: const Text('Video', style: TextStyle(color: Colors.white)),
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
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['fecha'] ?? '',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          data['nombre'] ?? '',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 30),
                        const Text(
                          'Descripción:',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data['desc'] ?? '',
                          style: const TextStyle(fontSize: 16, height: 1.4),
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
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => FractionallySizedBox(
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
                      itemBuilder: (context, index) => Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ZoomPage(assetPath: archivos[index]),
                                ),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
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
                                    errorBuilder: (_, error, stackTrace) =>
                                        const Icon(
                                          Icons.broken_image,
                                          size: 50,
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
                      ),
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
                        data['fecha'] ?? '',
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
                          onPressed: () =>
                              descargarImagen(context, archivos[paginaActual]),
                          icon: const Icon(Icons.cloud_download),
                          label: const Text('Descargar Imagen'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[800],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  Widget _buildCardNoticia(Map<String, dynamic> noticia) {
    return GestureDetector(
      onTap: () => _mostrarDetalleNoticia(context, noticia),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              child: Image.network(
                noticia['imagen'],
                width: double.infinity,
                fit: BoxFit.contain,
                color: Colors.grey[100],
                colorBlendMode: BlendMode.dstOver,
                errorBuilder: (_, error, stackTrace) => const SizedBox(
                  height: 180,
                  child: Center(child: Icon(Icons.broken_image, size: 40)),
                ),
              ),
            ),
            ListTile(
              title: Text(
                noticia['titulo'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(noticia['fechaTexto']),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDetalleNoticia(
    BuildContext context,
    Map<String, dynamic> noticia,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: const Text('Noticia'),
            backgroundColor: Colors.green[800],
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  noticia['imagen'],
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        noticia['fechaTexto'],
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        noticia['titulo'],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 30),
                      Text(
                        noticia['contenido'],
                        style: const TextStyle(fontSize: 15, height: 1.5),
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
  }

  void _mostrarDetalleEvento(
    BuildContext context,
    Map<String, dynamic> evento,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              evento['titulo'] ?? '',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('📅 Fecha: ${evento['fechaTexto']} ${evento['horaTexto']}'),
            const SizedBox(height: 5),
            Text('📍 Lugar: ${evento['lugar']}'),
            if ((evento['indicaciones'] ?? '').isNotEmpty) ...[
              const SizedBox(height: 10),
              Text('ℹ️ Indicaciones: ${evento['indicaciones']}'),
            ],
          ],
        ),
      ),
    );
  }
}
