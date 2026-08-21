// --- imports (Recursos necesarios para crear funciones)---

// ignore_for_file: library_private_types_in_public_api, use_super_parameters, deprecated_member_use, avoid_print, avoid_unnecessary_containers, unnecessary_to_list_in_spreads, unused_import

import 'dart:io';
import 'package:camilo_verde/worlds/world_level.dart';
import 'package:flutter/material.dart';
// ignore: unnecessary_import
import 'package:flutter/services.dart';
// ignore: 
import 'package:google_fonts/google_fonts.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// ignore: 
import 'package:flame/game.dart';
// ignore: 
import 'package:flame/components.dart';
import 'package:video_thumbnail/video_thumbnail.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://mrjfpalzuozbpvlhkian.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1yamZwYWx6dW96YnB2bGhraWFuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIxNjcyNTksImV4cCI6MjA4Nzc0MzI1OX0.JVDVzLZm4zNZMabnSSc1FcM4lXN-v6acLJOKl3ZiFco',
  );
  runApp(CamiloVerdeApp());
}


// --- bases --- 


class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _indiceActual = 0;
  int _contadorHuevoPascua = 0;

  // Lista de pantallas que se mostrarán según el botón presionado
  final List<Widget> _paginas = [
    const SeccionInicio(),
    const SeccionGaleria(),
    const SeccionInfo(),
    const SeccionEventos(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(  
        backgroundColor: Colors.transparent, // Lo mantenemos transparente
      elevation: 0,
      title: Row(
        children: [
          // --- LOGO DETECTOR DE TOQUES ---
          GestureDetector(
            onTap: () {
              // Incrementamos el contador al tocar
              _contadorHuevoPascua++;

              if (_contadorHuevoPascua == 3) {
                // ¡LO LOGRASTE! Reseteamos y lanzamos el juego
                _contadorHuevoPascua = 0;

                // Navegamos a la pantalla del juego (que definiremos en el Paso 3)
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SeccionInicio()),
                );
              }
            },
            child: Image.asset(
              'assets/images/camiloverdefulllogo.png', // Tu logo de la foto
              height: 100,
            ),
          ),
        ]
      ),
  
  scrolledUnderElevation: 0,
  ),
    body: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/fondo1.jpg'), // Tu imagen de fondo
          fit: BoxFit.cover, // Para que cubra toda la pantalla
          opacity: 0.3, // Ajusta la opacidad para que el texto sea legible
        ),
      ),
      child: _paginas[_indiceActual],
    ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceActual,
        type: BottomNavigationBarType.fixed, // Úsalo si tienes más de 3 ítems
        onTap: (index) {
          setState(() {
            _indiceActual = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.photo_library), label: 'Galería'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Nosotros'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Eventos'),
        ],
      ),
    );
  }
}

class CamiloVerdeApp extends StatelessWidget {
  const CamiloVerdeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CAMILO VERDE',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 246, 247 , 221)),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white, 
        textTheme: GoogleFonts.unboundedTextTheme(), 
      ),
      home: const PantallaPrincipal(),
    );
    }
}
    

// --- Aquí se define el contenido de cada sección  ---


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

  @override
  void initState() {
    super.initState();
    _cargarNoticiasDeSheets();
    _cargarFotosRecientesDeSheets();
    _cargarEventosProximos();
  }

  // --- 1. JALA LAS NOTICIAS ---
  Future<void> _cargarNoticiasDeSheets() async {
    // PEGA AQUÍ TU ENLACE TSV DE LA PESTAÑA NOTICIAS
    final url = Uri.parse('https://docs.google.com/spreadsheets/d/e/2PACX-1vTPerdxQc0PYwbODRCUyF3NTZ5O1xZ1D1xEWnaEGvd-o47lqwbsOZz8BD_hqFhEat9wWehMi-aAZau4/pub?gid=1627066775&single=true&output=tsv'); 

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
              'titulo': celdas[0].trim(),
              'imagen': celdas[1].trim(),
              'fechaTexto': celdas[2].trim(),
              'contenido': celdas[3].trim(),
            });
          }
        }
        setState(() {
          noticiasDinamicas = temporal;
          cargandoNoticias = false;
        });
      }
    } catch (e) {
      //ignore:
      print("Error cargando noticias: $e");
      setState(() => cargandoNoticias = false);
    }
  }

  // --- 2. JALA LAS FOTOS DE EVIDENCIAS ---
 Future<void> _cargarFotosRecientesDeSheets() async {
  final url = Uri.parse('https://docs.google.com/spreadsheets/d/e/2PACX-1vTPerdxQc0PYwbODRCUyF3NTZ5O1xZ1D1xEWnaEGvd-o47lqwbsOZz8BD_hqFhEat9wWehMi-aAZau4/pub?gid=0&single=true&output=tsv'); 

  try {
    final respuesta = await http.get(url);
    if (respuesta.statusCode == 200) {
      String tsvTexto = utf8.decode(respuesta.bodyBytes);
      List<String> lineas = tsvTexto.split('\n');
      List<Map<String, dynamic>> todasLasEvidencias = [];

      for (int i = 1; i < lineas.length; i++) {
        if (lineas[i].trim().isEmpty) continue;
        List<String> celdas = lineas[i].split('\t');

        if (celdas.length >= 4) {
          todasLasEvidencias.add({
            'nombre': celdas[0].trim(),
            'fecha': celdas[1].trim(),
            'imagenes': celdas[2].trim().split(';'),
            'desc': celdas[3].trim(),
          });
        }
      }

      setState(() {
        // Tomamos las últimas 3 evidencias completas subidas al Excel
        setState(() {
          // 1. Ordenamos toda la lista de evidencias por fecha (de la más nueva a la más vieja)
          todasLasEvidencias.sort((a, b) {
            DateTime fechaA = DateTime.tryParse(a['fecha']) ?? DateTime(2000);
            DateTime fechaB = DateTime.tryParse(b['fecha']) ?? DateTime(2000);
            return fechaB.compareTo(fechaA); // El más reciente primero
          });

          // 2. Ahora sí, tomamos las 3 que quedaron arriba después de ordenar
          fotosRecientes = todasLasEvidencias.take(3).toList(); 
          
          cargandoFotos = false;
        });
      });
    }
  } catch (e) {
 
    print("Error cargando fotos de bienvenida: $e");
    setState(() => cargandoFotos = false);
  }
}

 Future<void> _cargarEventosProximos() async {
  // Asegúrate de que estas variables estén declaradas en tu State:
  // List<Map<String, dynamic>> eventosProximos = [];
  // bool cargandoEventos = true;

  final url = Uri.parse('https://docs.google.com/spreadsheets/d/e/2PACX-1vTPerdxQc0PYwbODRCUyF3NTZ5O1xZ1D1xEWnaEGvd-o47lqwbsOZz8BD_hqFhEat9wWehMi-aAZau4/pub?gid=650159&single=true&output=tsv'); 

  try {
    final respuesta = await http.get(url);
    if (respuesta.statusCode == 200) {
      String tsvTexto = utf8.decode(respuesta.bodyBytes);
      List<String> lineas = tsvTexto.split('\n');
      List<Map<String, dynamic>> todosLosEventos = [];
      DateTime ahora = DateTime.now();

      // Empezamos en i = 1 para saltar el encabezado del Excel
      for (int i = 1; i < lineas.length; i++) {
        if (lineas[i].trim().isEmpty) continue;
        List<String> celdas = lineas[i].split('\t');

        // Verificamos que la fila tenga al menos las columnas básicas (Título y Fecha)
        if (celdas.length >= 2) {
          // Intentamos parsear la fecha de la columna B (índice 1)
          DateTime fechaEvento = DateTime.tryParse(celdas[1].trim()) ?? DateTime(2000);
          
          // FILTRO CRÍTICO: Solo eventos futuros o de hoy
          // Comparamos con el inicio del día de hoy para no borrar eventos que están pasando
          DateTime hoyInicio = DateTime(ahora.year, ahora.month, ahora.day);

          if (fechaEvento.isAfter(hoyInicio) || fechaEvento.isAtSameMomentAs(hoyInicio)) {
            todosLosEventos.add({
              'titulo': celdas[0].trim(),
              'fecha': fechaEvento,
              'fechaTexto': celdas.length > 2 ? celdas[2].trim() : "",
              'horaTexto': celdas.length > 3 ? celdas[3].trim() : "",
              'lugar': celdas.length > 4 ? celdas[4].trim() : "",
              'imagen': celdas.length > 5 ? celdas[5].trim() : "",
              'indicaciones': celdas.length > 6 ? celdas[6].trim() : "",
              'icono': celdas.length > 7 ? celdas[7].trim() : "event",
            });
          }
        }
      }

      if (mounted) {
        setState(() {
          // 1. Ordenamos cronológicamente (el más cercano primero)
          todosLosEventos.sort((a, b) => a['fecha'].compareTo(b['fecha']));
          
          // 2. Tomamos solo los 2 eventos más próximos para la vista de Inicio
          eventosProximos = todosLosEventos.take(2).toList();
          cargandoEventos = false;
        });
      }
    }
  } catch (e) {
    debugPrint("Error en Inicio - Eventos: $e");
    if (mounted) {
      setState(() => cargandoEventos = false);
    }
  }
}
  

 @override
Widget build(BuildContext context) {
  if (cargandoNoticias || cargandoFotos) {
    return const Center(child: CircularProgressIndicator(color: Colors.green));
  }

  // --- NUEVA LÓGICA DE ORGANIZACIÓN ---
  // Organizamos todos los elementos en una lista acolchada
  final contenidoColumna = [
    _buildSeccionTitulo("Últimas noticias Camilistas"),
    const SizedBox(height: 10),
    
    if (noticiasDinamicas.isEmpty)
      const Text("No hay noticias cargadas hoy")
    else
      _buildCardNoticia(
        context,
        noticiasDinamicas.first['titulo'],
        noticiasDinamicas.first['imagen'],
        noticiasDinamicas.first['fechaTexto'],
        noticiasDinamicas.first['fechaTexto'],
        noticiasDinamicas.first['contenido'],
      ),

    const SizedBox(height: 25),
    _buildSeccionTitulo("Multimedia reciente"),
    const SizedBox(height: 10),
    
    if (fotosRecientes.isEmpty)
      const Text("No hay multimedia reciente")
    else
      // LA MAGIA: Metemos el carrusel y su info en una Card contenedora
     Card(
  elevation: 6,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, // Alinea el texto a la izquierda
    children: [
      SizedBox(
        height: 500,
        child: Builder(
                builder: (context) {
                  // Tomamos la lista original de enlaces de la última fila subida
                  List<String> enlacesOriginales = List<String>.from(fotosRecientes.first['imagenes']);
                  
                  // Creamos una nueva lista donde los videos se conviertan en fotos miniatura para el carrusel de bienvenida
                  List<String> enlacesProcesados = enlacesOriginales.map((url) {
                    bool esVideo = url.toLowerCase().contains('.mp4') || 
                                   url.toLowerCase().contains('.mov') || 
                                   url.contains('video/upload');
                    
                    // Si detecta un formato de video de Cloudinary, pide el fotograma JPG en su lugar
                    if (esVideo) {
                      return url.replaceAll('.mp4', '.jpg').replaceAll('.mov', '.jpg');
                    }
                    return url;
                  }).toList();

                  // Le pasamos la lista de miniaturas limpias a tu carrusel existente
                  return buildCarrusel(
                    enlacesProcesados, 
                    fotosRecientes.first, 
                    context
                  );
                },
              ),
            ),
      

      Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Última evidencia subida", // El nombre del grupo
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              "Explora esta y todas las más recientes evidencias de nuestro proyecto ambiental en la sección Galería.", // La descripción
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
          ],
        ),
      ),
      const SizedBox(height: 5),


    const SizedBox(height: 5), // Espacio final para el menú inferior// --------------------------------------------
    ],
  ),
),
const SizedBox(height: 25),
    _buildSeccionTitulo("Próximos Eventos"),
    const SizedBox(height: 10),

    if (eventosProximos.isEmpty)
      const Text("No hay eventos programados próximamente")
    else
      // Creamos una lista pequeña de tarjetas de eventos
      ...eventosProximos.map((evento) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.green[100], shape: BoxShape.circle),
            child: const Icon(Icons.calendar_today, color: Colors.green, size: 20),
          ),
          title: Text(evento['titulo'], style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("${evento['fechaTexto']} - ${evento['horaTexto']}"),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () => _mostrarDetalleEvento(context, evento), // Reutiliza tu función de detalles
        ),
        //ignore:
      )).toList(),

    const SizedBox(height: 5), // Espacio final para el menú inferior
    // Un espacio extra abajo para que el menú no se coma la información al final del scroll
    const SizedBox(height: 5), 
  ];
  // -----------------------------------

  // Envolvemos todo en el RefreshIndicator y el ListView para el scroll
  return RefreshIndicator(
    onRefresh: () async {
      _cargarNoticiasDeSheets();
      _cargarFotosRecientesDeSheets();
    },
    color: Colors.green,
    child: ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      // Mantenemos el padding original
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0), 
      children: contenidoColumna,
    ),
  );
}

  // --- Mantenemos tus funciones auxiliares abajo del archivo exactamente igual ---
  Widget _buildSeccionTitulo(String titulo) {
    return Text(titulo, style: GoogleFonts.unbounded(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[800]));
  }

  Widget _buildCardNoticia(BuildContext context, String titulo, String imagen, String subtitulo, String fecha, String contenidoCompleto) {
    return GestureDetector(
      onTap: () => _mostrarDetalleNoticia(context, titulo, imagen, fecha, contenidoCompleto),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network( // <-- Cambiamos de .asset a .network para las fotos de la nube
                imagen, 
                height: 300, 
                width: double.infinity, 
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(height: 300, child: Center(child: Icon(Icons.broken_image, size: 50))),
              ),
            ),
            ListTile(
              title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(subtitulo),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  // La función _mostrarDetalleNoticia la tienes global al final de main.dart, déjala allá sin cambiarla

 void _mostrarDetalleNoticia(BuildContext context, String titulo, String imagen, String fecha, String contenido) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Noticia", style: TextStyle(fontSize: 18)),
        backgroundColor: const Color.fromARGB(255, 246, 247, 221),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen con opción de Zoom al tocarla
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ZoomPage(assetPath: imagen))),
              child: Image.network(imagen, width: double.infinity, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fecha, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(titulo, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const Divider(height: 30),
                  Text(contenido, style: const TextStyle(fontSize: 16, height: 1.6)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }));
}
}

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
  // PEGA AQUÍ TU NUEVO ENLACE QUE TERMINA EN =tsv
  final url = Uri.parse('https://docs.google.com/spreadsheets/d/e/2PACX-1vTPerdxQc0PYwbODRCUyF3NTZ5O1xZ1D1xEWnaEGvd-o47lqwbsOZz8BD_hqFhEat9wWehMi-aAZau4/pub?output=tsv');

  

  try {
    final respuesta = await http.get(url);
    if (respuesta.statusCode == 200) {
      
      // Decodificamos con UTF-8 para las tildes
      String tsvTexto = utf8.decode(respuesta.bodyBytes); 
      
      List<String> lineas = tsvTexto.split('\n');
      List<Map<String, dynamic>> temporal = [];

      for (int i = 1; i < lineas.length; i++) {
        if (lineas[i].trim().isEmpty) continue;
        
        // LA MAGIA: Dividimos por Tabulador (\t), ignorando las comas del texto
        List<String> celdas = lineas[i].split('\t');

        // Nos aseguramos de que la fila tenga al menos las 4 columnas requeridas
        if (celdas.length >= 4) {
          temporal.add({
            'nombre': celdas[0].trim(),
            'fecha': celdas[1].trim(),
            'imagenes': celdas[2].trim().split(';'), // Fotos separadas por punto y coma
            'desc': celdas[3].trim(), // ¡Aquí ya puedes poner comas normales!
          });
        }
      }

      setState(() {
        evidencias = temporal;
        cargando = false;
        _ordenarAlCargar(); 
      });
    }
  } catch (e) {
    print("Error conectando a Sheets: $e");
    setState(() => cargando = false);
  }
}

        void _ordenarAlCargar() {
          evidencias.sort((a, b) => _parseFecha(b['fecha']).compareTo(_parseFecha(a['fecha'])));
        }


      void _ordenarGaleria() {
          setState(() {
            _ascendente = !_ascendente;
            evidencias.sort((a, b) {
              DateTime fechaA = _parseFecha(a['fecha']);
              DateTime fechaB = _parseFecha(b['fecha']);
              return _ascendente ? fechaA.compareTo(fechaB) : fechaB.compareTo(fechaA);
            });
          });
        }

       DateTime _parseFecha(dynamic fecha) {
  // 1. Validamos que la fecha no sea nula
          if (fecha == null) return DateTime(2000);
          
          // 2. Si ya es un DateTime (a veces pasa), lo devolvemos tal cual
          if (fecha is DateTime) return fecha;

          try {
            String fechaStr = fecha.toString();
            // 3. Detectamos si usa guion o barra para separar
            String separador = fechaStr.contains('-') ? '-' : '/';
            List<String> partes = fechaStr.split(separador);

            // 4. LÓGICA SEGÚN TU IMAGEN (Año-Mes-Día)
            // partes[0] = Año (2025)
            // partes[1] = Mes (07)
            // partes[2] = Día (18)
            return DateTime(
              int.parse(partes[0]), 
              int.parse(partes[1]), 
              int.parse(partes[2])
            );
          } catch (e) {
            // ignore: 
            print("Error parseando fecha: $e");
            return DateTime(2000); // Fecha de respaldo para que no explote la app
          }
        }


      @override
      Widget build(BuildContext context) {
        if (cargando) {
          return const Center(child: CircularProgressIndicator(color: Colors.green));
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
              const Text("Evidencias", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: _ordenarGaleria,
                icon: Icon(_ascendente ? Icons.arrow_upward : Icons.arrow_downward, size: 18, color: Colors.green),
                label: Text(_ascendente ? "Más antiguos" : "Más nuevos", style: const TextStyle(color: Colors.green)),
                style: TextButton.styleFrom(
                  // ignore: 
                  backgroundColor: Colors.green.withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.8, // Ajusta esto para que quepa el texto abajo // Dos columnas como en Instagram

              ),
              itemCount: evidencias.length,
              itemBuilder: (context, index) {
                final Map<String, dynamic> evidencia = evidencias[index];
                return Card(
                  elevation: 4,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    onTap: () => _mostrarDetalle(context, evidencia),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white, // Fondo blanco para que se note el área de texto
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          // 1. ÁREA DE IMAGEN (Ocupa todo el espacio sobrante)
                          Expanded(
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: ClipRRect(
                                    // Solo redondeamos las esquinas superiores para que encaje con el fondo blanco
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                    child:
                                    (evidencia['imagenes'][0].toLowerCase().contains('.mp4') ||
                                       evidencia['imagenes'][0].toLowerCase().contains('.mov') ||
                                        evidencia['imagenes'][0].contains('video/upload'))
                                            // USAMOS EL NUEVO WIDGET SI ES VIDEO
                                            ? MiniaturaVideo(
                                                videoUrl: evidencia['imagenes'][0],
                                                fit: BoxFit.cover,
                                          )                                    
                                     : Image.network(
                                      evidencia['imagenes'][0],
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                                        },
                                    ),
                                  ),
                                ),
                                 if (evidencia['imagenes'][0].contains('video/upload') || evidencia['imagenes'][0].endsWith('.mp4'))
                                    const Center(
                                      child: Icon(Icons.play_circle_fill, color: Colors.white70, size: 40),
                                    ),
                                // El icono se mantiene intacto en su esquina
                                if (evidencia['imagenes'].length > 1)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: const Icon(Icons.collections, color: Colors.white, size: 14),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          
                          // 2. ÁREA DE TEXTO CON TAMAÑO FIJO (Evita espacios extra)
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min, 
                              children: [
                                Text(
                                  evidencia['nombre'],
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
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
                  )
                );
                
              },
              )
         )
         )
              ]
              );
              
                      
             }
             
      

     
      
      
    
  
  
  
  

}

class SeccionInfo extends StatelessWidget {
  const SeccionInfo({super.key});

  Future<void> _abrirEnlace(String url) async {
  final Uri uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw Exception('No se pudo abrir $url');
  }
}

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(25.0),
      children: [
        _buildSeccionTitulo("¿Quienes somos?"),
        const SizedBox(height: 10),

        _buildCuadroDeTextobold("El PRAE CAMILO VERDE pertenece a la:"),

        ClipRRect(
        borderRadius: BorderRadius.circular(5), // Bordes redondeados de 20px
        child: Image.asset(
          'assets/images/camilotorreslogo.png',
          width: 350, // Ajusta el ancho en píxeles
          height: 350, // Ajusta el alto
          fit: BoxFit.contain, // Evita que el logo se deforme
          ),
        ),

        const SizedBox(height:5),

        _buildCuadroDeTexto2("Aprobada por las Resoluciones:"),
        const SizedBox(height: 5),
        _buildCuadroDeTexto2("Nº 0846 de mayo 30 de 2002"),
        _buildCuadroDeTexto2("Nº 0364 de diciembre de 2001"),
        _buildCuadroDeTexto2("Nº 1259 de junio 17 de 1998 ") ,
        _buildCuadroDeTexto2("N° 1071 de 18 de 2004 "),
        _buildCuadroDeTexto2("código del ICFES 096446 "),
        _buildCuadroDeTexto2("código DANE 113001000771"),
        _buildCuadroDeTexto2("NIT 806003674-1"),
         const SizedBox(height: 18),

        _buildCuadroDeTexto("Somos una institución educativa de carácter oficial ubicada en el barrio El Pozón de la ciudad de Cartagena de Indias."),
        const SizedBox(height: 10),
        _buildCuadroDeTexto("Ofrecemos el servicio educativo en los niveles de preescolar, básica primaria, básica secundaria y nocturna."),
        const SizedBox(height: 50),


        ElevatedButton(
          onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true, // Permite que crezca si hay mucho texto
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  
                  mainAxisSize: MainAxisSize.min, // Aquí sí funcionará perfecto
                  children: [
                    Text(
                      "NUESTRA MISIÓN",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.unbounded(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                        letterSpacing: 2.0,
                      ),
                    ),

                    const SizedBox(height: 15),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset('assets/images/colegio.jpg', fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Somos una Institución Educativa de carácter oficial, que brinda a sus estudiantes una formación integral, fundamentada en la convivencia democrática, el pensamiento crítico, científico y tecnológico; que les permita satisfacer sus necesidades y las de su contexto.",
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                       style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[800], // Color de fondo (verde proyecto)
                        foregroundColor: Colors.white, // Color del texto
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15), // Tamaño del botón
                        textStyle: GoogleFonts.unbounded(fontSize: 14, fontWeight: FontWeight.normal), // Tu fuente
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // Bordes menos redondeados
                        ),
                        elevation: 5, // Sombra para que "flote"
                      ),
                      child: const Text("Entendido"),
                    ),
                  ],
                ),
              );
            },
          );
          },
           style: ElevatedButton.styleFrom(
           backgroundColor: Colors.green[800], // Color de fondo (verde proyecto)
            foregroundColor: Colors.white, // Color del texto
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15), // Tamaño del botón
            textStyle: GoogleFonts.unbounded(fontSize: 14, fontWeight: FontWeight.normal), // Tu fuente
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Bordes menos redondeados
            ),
            elevation: 5, // Sombra para que "flote"
          ),
          child: const Text("Nuestra Misión"),
        ),
        const SizedBox(height: 20),


        ElevatedButton(
          onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true, // Permite que crezca si hay mucho texto
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Aquí sí funcionará perfecto
                  children: [
                     Text(
                      "NUESTRA VISIÓN",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.unbounded(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                        letterSpacing: 2.0,
                      ),
                    ),

                    const SizedBox(height: 15),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset('assets/images/camilotorres.jpg', fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Seremos en el 2026 una institución Educativa reconocida por su compromiso con el desarrollo integral de los estudiantes y las competencias necesarias para contribuir en la transformación social.",
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[800], // Color de fondo (verde proyecto)
                        foregroundColor: Colors.white, // Color del texto
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15), // Tamaño del botón
                        textStyle: GoogleFonts.unbounded(fontSize: 14, fontWeight: FontWeight.normal), // Tu fuente
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // Bordes menos redondeados
                        ),
                        elevation: 5, // Sombra para que "flote"
                      ),
                      child: const Text("Entendido"),
                    ),
                  ],
                ),
              );
            },
          );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[800], // Color de fondo (verde proyecto)
            foregroundColor: Colors.white, // Color del texto
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15), // Tamaño del botón
            textStyle: GoogleFonts.unbounded(fontSize: 14, fontWeight: FontWeight.normal), // Tu fuente
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Bordes menos redondeados
            ),
            elevation: 5, // Sombra para que "flote"
          ),
          child: const Text("Nuestra Visión"),
        ),     
        const SizedBox(height: 20),

        ElevatedButton(
  onPressed: () {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // en true para que pueda ocupar casi toda la pantalla
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // DraggableScrollableSheet es ideal para FAQ en modales
        return DraggableScrollableSheet(
          initialChildSize: 0.9, // Empieza ocupando el 60% de la pantalla
          maxChildSize: 0.9,     // Puede crecer hasta el 90%
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView( 
                controller: scrollController,
                children: [
                  Text(
                    "PREGUNTAS FRECUENTES(FAQ)",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.unbounded(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[900],
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset('assets/images/colegio.jpg', fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 20),

                  ExpansionTile(
                    textColor: const Color(0xFF2E7D32),
                    collapsedTextColor: Colors.black87,
                    iconColor: const Color(0xFF2E7D32),
                    collapsedIconColor: Colors.green,
                    title: Text(
                      "¿Qué es PRAE CAMILO VERDE?",
                      style: GoogleFonts.unbounded( 
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "★ 'CAMILO VERDE' es nuestro Proyecto Ambiental Escolar (PRAE).",
                          style: GoogleFonts.unbounded(fontSize: 14),
                        ),
                      ),
                    ],
                  ),

                  ExpansionTile(
                    textColor: const Color(0xFF2E7D32),
                    collapsedTextColor: Colors.black87,
                    iconColor: const Color(0xFF2E7D32),
                    collapsedIconColor: Colors.green,
                    title: Text(
                      "¿Cuál es el propósito de Camilo Verde?",
                      style: GoogleFonts.unbounded( // <--- Usa GoogleFonts directamente aquí
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "★ CAMILO VERDE busca integrar la dimensión ambiental en toda la vida del colegio, y por eso, su objetivo es fomentar una cultura de sostenibilidad en toda la comunidad Camilista.",
                          style: GoogleFonts.unbounded(fontSize: 14),
                        ),
                      ),
                    ],
                  ),

                  ExpansionTile(
                    textColor: const Color(0xFF2E7D32),
                    collapsedTextColor: Colors.black87,
                    iconColor: const Color(0xFF2E7D32),
                    collapsedIconColor: Colors.green,
                    title: Text(
                      "¿Por qué Camilo Verde?",
                      style: GoogleFonts.unbounded( // <--- Usa GoogleFonts directamente aquí
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "★ Como institución educativa, tenemos el deber de formar ciudadanos conscientes y activos en el cuidado del medio ambiente, ya que vivimos en un momento clave para el planeta, mientras problemas como la contaminación y consumo excesivo nos afectan a todos, transformamos el colegio en un 'Laboratorio vivo de sostenibilidad', donde aprendemos en la práctica.\n\nQueremos que cada acción en el colegio cuente para un futuro más verde en nuestra comunidad.",
                          style: GoogleFonts.unbounded(fontSize: 14),
                        ),
                      ),
                    ],
                  ),

                   ExpansionTile(
                    textColor: const Color(0xFF2E7D32),
                    collapsedTextColor: Colors.black87,
                    iconColor: const Color(0xFF2E7D32),
                    collapsedIconColor: Colors.green,
                    title: Text(
                       "¿Cuál ha sido el impácto del proyecto?",
                      style: GoogleFonts.unbounded( 
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "★ Esta iniciativa ha repercutido en la comunidad Camilista, e incluso, en la del barrio El Pozón de gran manera, al resultar para los estudiantes y sus familias/conocidos, una vía segura para aprender y aplicar sus conocimientos en el cuidado del medio ambiente.",
                        ),
                      ),
                    ],
                  ),

                  ExpansionTile(
                    textColor: const Color(0xFF2E7D32),
                    collapsedTextColor: Colors.black87,
                    iconColor: const Color(0xFF2E7D32),
                    collapsedIconColor: Colors.green,
                    title: Text(
                       "¿Quienes lo dirigen?",
                      style: GoogleFonts.unbounded( 
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "★ Adelis Herrera - Docente \n★ Emma Moreno - Docente  \n★ Euclides de las Aguas - Rector",
                     textAlign: TextAlign.left,
                      ),
                      
                      ),
                    ],
                  ),

                  ExpansionTile(
                    textColor: const Color(0xFF2E7D32),
                    collapsedTextColor: Colors.black87,
                    iconColor: const Color(0xFF2E7D32),
                    collapsedIconColor: Colors.green,
                    title: Text(
                      "Qué es una Recogetón?",
                      style: GoogleFonts.unbounded(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "★ Una Recogetón es una actividad de recolección de residuos sólidos en el área escolar, con el objetivo de promover la conciencia ambiental y la responsabilidad ciudadana.",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: GoogleFonts.unbounded(fontSize: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Entendido"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green[800],
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
    textStyle: GoogleFonts.unbounded(fontSize: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    elevation: 5,
  ),
  child: const Text("PREGUNTAS FRECUENTES(FAQ)"),
),

     const SizedBox(height: 40),

        _buildSeccionTitulo("Contáctanos"),
        const SizedBox(height: 10),
        _buildCuadroDeTexto("Contamos con dos sedes:"),
        const SizedBox(height:20),
        _buildSeccionTitulo2("-Sede Principal:"),
        _buildCuadroDeTextobold("- Camilo Torres del Pozón", alinear: TextAlign.center),
        const SizedBox(height:5),
        _buildCuadroDeTextobold("- Dirección: EL POZÓN - Mz. 49, Lote 13, Cr. 89", alinear: TextAlign.center),
        const SizedBox(height: 20),
        _buildSeccionTitulo2("-Sede de Primaria:"),
        _buildCuadroDeTextobold("- Nuevo Horizonte - Escuela Distrital Los Chulianes", alinear: TextAlign.center),
         const SizedBox(height:5),
        _buildCuadroDeTextobold("- Dirección: EL POZÓN - Tv. 56, #87-46", alinear: TextAlign.center),
         const SizedBox(height:5),
        _buildCuadroDeTextobold("- DANE: 113001000275", alinear: TextAlign.center),
        const SizedBox(height: 50),

        _buildCuadroDeTexto("Más formas de contactarnos:"),
        const SizedBox(height:20),

        _buildSeccionTitulo2("-Página Web:"),
        const SizedBox(height:5),

      RichText(
        text: TextSpan(
          // Estilo base para que coincida con tu app
          style: const TextStyle( color: Colors.black, fontSize: 16, height: 1.5),
          children: [
            TextSpan(text: "Sitio oficial de la I.E. Camilo Torres: ",
            style: GoogleFonts.unbounded(
                color: Color.fromARGB(255, 0, 0, 0), // Puedes cambiar el azul por un verde acorde a "Camilo Verde"
                fontSize: 18, // Cambia el tamaño de la letra
                fontWeight: FontWeight.w400, // Hazla más gruesa o delgada
                fontStyle: FontStyle.normal, // Opcional: ponerlo en cursiva
                decoration: TextDecoration.none, // Quita el subrayado si te molesta
                letterSpacing: 1.2
            ),

            ),
            TextSpan(
              text: "iectp.edu.co",
              style: GoogleFonts.unbounded(
                color: Color.fromARGB(255, 18, 117, 255), // Puedes cambiar el azul por un verde acorde a "Camilo Verde"
                fontSize: 18, // Cambia el tamaño de la letra
                fontWeight: FontWeight.w500, // Hazla más gruesa o delgada
                fontStyle: FontStyle.normal, // Opcional: ponerlo en cursiva
                decoration: TextDecoration.underline, // Quita el subrayado si te molesta
                letterSpacing: 1.2,
                
                
              ),
              // Reconocedor para que el link sea clickeable
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // Aquí pones el link que quieras abrir
                  _abrirEnlace('https://iectp.edu.co/'); 
                },
            ),
          ],
        ),
      ),

       const SizedBox(height: 30),
      _buildSeccionTitulo2("-Redes Sociales:"),
      const SizedBox(height:5),

      RichText(
        text: TextSpan(
          // Estilo base para que coincida con tu app
          style: const TextStyle( color: Colors.black, fontSize: 16, height: 1.5),
          children: [
            TextSpan(text: "Instagram: ",
            style: GoogleFonts.unbounded(
                color: Color.fromARGB(255, 0, 0, 0), // Puedes cambiar el azul por un verde acorde a "Camilo Verde"
                fontSize: 18, // Cambia el tamaño de la letra
                fontWeight: FontWeight.w400, // Hazla más gruesa o delgada
                fontStyle: FontStyle.normal, // Opcional: ponerlo en cursiva
                decoration: TextDecoration.none, // Quita el subrayado si te molesta
                letterSpacing: 1.2
            )
            ),
            TextSpan(
              text: "@ie_camilotorres",
              style: GoogleFonts.unbounded(
                color: Color.fromARGB(255, 18, 117, 255), // Puedes cambiar el azul por un verde acorde a "Camilo Verde"
                fontSize: 18, // Cambia el tamaño de la letra
                fontWeight: FontWeight.w500, // Hazla más gruesa o delgada
                fontStyle: FontStyle.normal, // Opcional: ponerlo en cursiva
                decoration: TextDecoration.underline, // Quita el subrayado si te molesta
                letterSpacing: 1.2,
              ),
              // Reconocedor para que el link sea clickeable
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // Aquí pones el link que quieras abrir
                  _abrirEnlace('https://www.instagram.com/ie_camilotorres/'); 
                },
            ),
          ],
        ),
      ),

 const SizedBox(height: 20),

      RichText(
        text: TextSpan(
          // Estilo base para que coincida con tu app
          style: const TextStyle( color: Colors.black, fontSize: 16, height: 1.5),
          children: [
            TextSpan(text: "Facebook: ",
            style: GoogleFonts.unbounded(
                color: Color.fromARGB(255, 0, 0, 0), // Puedes cambiar el azul por un verde acorde a "Camilo Verde"
                fontSize: 18, // Cambia el tamaño de la letra
                fontWeight: FontWeight.w400, // Hazla más gruesa o delgada
                fontStyle: FontStyle.normal, // Opcional: ponerlo en cursiva
                decoration: TextDecoration.none, // Quita el subrayado si te molesta
                letterSpacing: 1.2
            ),
            ),
            TextSpan(
              text: "@IEOCAMILOTRRES",
              style: GoogleFonts.unbounded(
                color: Color.fromARGB(255, 18, 117, 255), // Puedes cambiar el azul por un verde acorde a "Camilo Verde"
                fontSize: 18, // Cambia el tamaño de la letra
                fontWeight: FontWeight.w500, // Hazla más gruesa o delgada
                fontStyle: FontStyle.normal, // Opcional: ponerlo en cursiva
                decoration: TextDecoration.underline, // Quita el subrayado si te molesta
                letterSpacing: 1.2,
              ),
              // Reconocedor para que el link sea clickeable
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // Aquí pones el link que quieras abrir
                  _abrirEnlace('https://www.facebook.com/IEOCAMILOTRRES/?locale=es_LA'); 
                },
            ),
          ],
        ),
      ),
  
 const SizedBox(height: 20),

      RichText(
        text: TextSpan(
          // Estilo base para que coincida con tu app
          style: const TextStyle( color: Colors.black, fontSize: 16, height: 1.5),
          children: [
            TextSpan(text: "Facebook de la Radio Escolar: ",
            style: GoogleFonts.unbounded(
                color: Color.fromARGB(255, 0, 0, 0), // Puedes cambiar el azul por un verde acorde a "Camilo Verde"
                fontSize: 18, // Cambia el tamaño de la letra
                fontWeight: FontWeight.w400, // Hazla más gruesa o delgada
                fontStyle: FontStyle.normal, // Opcional: ponerlo en cursiva
                decoration: TextDecoration.none, // Quita el subrayado si te molesta
                letterSpacing: 1.2
            ),
            ),
            TextSpan(
              text: "@Onda-Camilista",
              style: GoogleFonts.unbounded(
                color: Color.fromARGB(255, 18, 117, 255), // Puedes cambiar el azul por un verde acorde a "Camilo Verde"
                fontSize: 18, // Cambia el tamaño de la letra
                fontWeight: FontWeight.w500, // Hazla más gruesa o delgada
                fontStyle: FontStyle.normal, // Opcional: ponerlo en cursiva
                decoration: TextDecoration.underline, // Quita el subrayado si te molesta
                letterSpacing: 1.2,
              ),
              // Reconocedor para que el link sea clickeable
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // Aquí pones el link que quieras abrir
                  _abrirEnlace('https://www.facebook.com/people/Onda-Camilista/61578854836102/'); 
                },
            ),
          ],
        ),
      ),
      ],
    );
  }

  Widget _buildSeccionTitulo(String titulo) {
    return Text(titulo, style: GoogleFonts.unbounded(fontSize: 21,  fontWeight: FontWeight.bold, color: Colors.green[800], decoration: TextDecoration.underline,decorationColor: Colors.green[800]));
  }

  Widget _buildSeccionTitulo2(String titulo) {
    return Text(titulo, style: GoogleFonts.unbounded(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.green[800], decoration: TextDecoration.underline,decorationColor: Colors.green[800]));
  }

  Widget _buildCuadroDeTexto(String texto) {
    return Text(texto, style: GoogleFonts.unbounded(fontSize: 16, fontWeight: FontWeight.normal, color: Color.fromARGB(255, 0, 0, 0)));
  }

  Widget _buildCuadroDeTexto2(String texto) {
    return Text(texto, style: GoogleFonts.unbounded(fontSize: 9, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 112, 112, 112)));
  }

  Widget _buildCuadroDeTextobold(String texto, {TextAlign alinear = TextAlign.left}) {
    return Text(texto, textAlign: alinear, style: GoogleFonts.unbounded(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)));
  }
}

class SeccionEventos extends StatefulWidget {
  const SeccionEventos({super.key});

  @override
  State<SeccionEventos> createState() => _SeccionEventosState();
}
class _SeccionEventosState extends State<SeccionEventos> {
  List<Map<String, dynamic>> eventosDinamicos = [];
  bool cargando = true;
  bool _ascendente = true;
  
  void _ordenarEventos() {
    setState(() {
      _ascendente = !_ascendente;
      eventosDinamicos.sort((a, b) {
        DateTime fechaA = a['fecha'];
        DateTime fechaB = b['fecha'];
        return _ascendente ? fechaA.compareTo(fechaB) : fechaB.compareTo(fechaA);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _cargarEventosDeSheets();
  }

  Future<void> _cargarEventosDeSheets() async {
    // PEGA AQUÍ TU ENLACE TSV DE LA PESTAÑA EVENTOS
    final url = Uri.parse('https://docs.google.com/spreadsheets/d/e/2PACX-1vTPerdxQc0PYwbODRCUyF3NTZ5O1xZ1D1xEWnaEGvd-o47lqwbsOZz8BD_hqFhEat9wWehMi-aAZau4/pub?gid=650159&single=true&output=tsv');
                                        

    try {
      final respuesta = await http.get(url);
      if (respuesta.statusCode == 200) {
        String tsvTexto = utf8.decode(respuesta.bodyBytes);
        List<String> lineas = tsvTexto.split('\n');
        List<Map<String, dynamic>> temporal = [];

        for (int i = 1; i < lineas.length; i++) {
          if (lineas[i].trim().isEmpty) continue;
          List<String> celdas = lineas[i].split('\t');

          if (celdas.length >= 8) {
            temporal.add({
              'titulo': celdas[0].trim(),
              // Convertimos el texto "2026-03-26" a un objeto DateTime real de Flutter
              'fecha': DateTime.parse(celdas[1].trim()), 
              'fechaTexto': celdas[2].trim(),
              'horaTexto': celdas[3].trim(),
              'lugar': celdas[4].trim(),
              'imagen': celdas[5].trim(),
              'indicaciones': celdas[6].trim(),
              'icono': _mapearIcono(celdas[7].trim()), // Función traductora
            });
          }
        }

        setState(() {
          eventosDinamicos = temporal;
          cargando = false;
        });
      }
    } catch (e) {
      // ignore: 
      print("Error cargando eventos: $e");
      setState(() => cargando = false);
    }
  }

  // Traductor de texto a iconos de Flutter
  IconData _mapearIcono(String nombreIcono) {
    switch (nombreIcono) {
      case 'recycling': return Icons.recycling;
      case 'forest': return Icons.forest;
      case 'school': return Icons.school;
      default: return Icons.event; // Icono por defecto si te equivocas al escribir
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Center(child: CircularProgressIndicator(color: Colors.green));
    }

    if (eventosDinamicos.isEmpty) {
      return const Center(child: Text("No hay eventos programados"));
    }

    DateTime ahora = DateTime.now();

      // 1. Eventos Futuros (Hoy o después)
      List<Map<String, dynamic>> futuros = eventosDinamicos
          .where((evento) => evento['fecha'].isAfter(ahora) || evento['fecha'].isAtSameMomentAs(ahora))
          .toList();

      // 2. Eventos Pasados (Antes de hoy)
      List<Map<String, dynamic>> pasados = eventosDinamicos
          .where((evento) => evento['fecha'].isBefore(ahora))
          .toList();

      // --- APLICAMOS EL ORDENAMIENTO ELEGIDO ---
      futuros.sort((a, b) => _ascendente ? a['fecha'].compareTo(b['fecha']) : b['fecha'].compareTo(a['fecha']));
      pasados.sort((a, b) => _ascendente ? a['fecha'].compareTo(b['fecha']) : b['fecha'].compareTo(a['fecha']));

  // Unimos ambas listas para poner los futuros arriba y los pasados abajo
  List<Map<String, dynamic>> listaFinal = [...futuros, ...pasados];

   return Scaffold(
    backgroundColor: Colors.transparent,
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Eventos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: _ordenarEventos,
                icon: Icon(_ascendente ? Icons.arrow_upward : Icons.arrow_downward, size: 18, color: Colors.green),
                // El texto del botón cambia según tu elección
                label: Text(_ascendente ? "Cercano - Lejano" : "Lejano - Cercano", style: const TextStyle(color: Colors.green)),
                style: TextButton.styleFrom(
                  // ignore:
                  backgroundColor: Colors.green.withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _cargarEventosDeSheets,
            color: Colors.green,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              itemCount: listaFinal.length,
              itemBuilder: (context, index) {
                final evento = listaFinal[index];
                bool esPasado = evento['fecha'].isBefore(ahora);

                // Si es el primer evento pasado de la lista, dibujamos un encabezado de separación
                bool mostrarTituloPasados = esPasado && (index == 0 || !listaFinal[index - 1]['fecha'].isBefore(ahora));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (mostrarTituloPasados)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                        child: Text(
                          "🕒 Eventos Pasados",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                      ),
                    
                    // Opacamos la tarjeta si el evento ya pasó para darle un efecto visual apagado
                    Opacity(
                      opacity: esPasado ? 0.6 : 1.0, 
                      child: _buildEventoCardCompleta(context, evento, esPasado), // Le pasamos si ya pasó
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    ),
  );
}

 Widget _buildEventoCardCompleta(BuildContext context, Map<String, dynamic> evento, bool esPasado) {
  return Card(
    margin: const EdgeInsets.only(bottom: 20),
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: InkWell(
      onTap: () => _mostrarDetalleEvento(context, evento),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(
              evento['imagen'],
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: esPasado ? Colors.grey[300] : Colors.green[100],
              child: Icon(evento['icono'], color: esPasado ? Colors.grey : Colors.green),
            ),
            title: Text(
              evento['titulo'],
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 18,
                color: esPasado ? Colors.grey : Colors.black
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(evento['fechaTexto']),
                if (esPasado)
                  const Text(
                    "⚠️ Este evento ya finalizó",
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
              ],
            ),
            trailing: const Icon(Icons.info_outline, color: Colors.green),
          ),
        ],
      ),
    ),
  );
}

}



// --- Aquí se definen funciones globales utiles para el funcionamiento de la app ---



// -- Función para construir el carrusel de fotos en la sección de eventos
Widget buildCarrusel(List<String> fotos, Map<String, dynamic> evidencias, BuildContext context) {
  final PageController controlador = PageController();
  return GestureDetector(
    onTap: () => _mostrarDetalle(context, evidencias),
    child: Stack(
      children: [
        PageView.builder(
          controller: controlador,
          itemCount: fotos.length,
          itemBuilder: (context, i) => ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(fotos[i], fit: BoxFit.cover)
          ),
        ),
        // ... (puedes mantener tus flechas e indicadores aquí)
      ],
    ),
  );
}

// -- Función para mostrar detalles de una imagen
void _mostrarDetalle(BuildContext context, Map<String, dynamic> data) {
  List<String> archivos = List<String>.from(data['imagenes']);
  final String url = data['imagenes'][0];

  final PageController detalleController = PageController();
  int paginaActual = 0;

  bool esVideo = url.toLowerCase().contains('.mp4') || 
                 url.toLowerCase().contains('.mov') ||
                 url.contains('video/upload');

  if (esVideo) {
    // Si es video, vamos directo al reproductor que creamos
   Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.white, // Fondo blanco para que combine con el panel
          appBar: AppBar(
            backgroundColor: Colors.green, // Color de tu proyecto Camilo Verde
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text("Video", style: TextStyle(color: Colors.white)),
            actions: [
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () => _descargarVideo(url),
              ),
            ],
          ),
          body: SingleChildScrollView( // Permite desplazar si hay mucho texto
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. EL VIDEO (Con un alto fijo para evitar bordes negros)
                Container(
                  color: Colors.black,
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.3, // Ocupa el 40% de la pantalla
                  child: Center(
                    child: VisorMultimedia(path: url),
                  ),
                ),
                
                // 2. PANEL DE INFORMACIÓN
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
                              fontSize: 14
                            ),
                          ),
                          const Icon(Icons.video_library, color: Colors.grey, size: 20),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        data['nombre'] ?? "",
                        style: const TextStyle(
                          fontSize: 24, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.black,
                          letterSpacing: -0.5
                        ),
                      ),
                      const Divider(height: 30, thickness: 1),
                      const Text(
                        "Descripción:",
                        style: TextStyle(
                          fontSize: 14, 
                          fontWeight: FontWeight.w500, 
                          color: Colors.grey
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data['desc'] ?? "",
                        style: const TextStyle(
                          fontSize: 17, 
                          color: Colors.black87, 
                          height: 1.4 // Mejora la lectura del texto largo
                        ),
                      ),
                      const SizedBox(height: 40), // Espacio final
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
      builder: (context, setState) {
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
                      onPageChanged: (index) => setState(() => paginaActual = index),
                      itemBuilder: (context, index) {
                        return Center(
                          child: IntrinsicWidth(
                            child: IntrinsicHeight(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ZoomPage(assetPath: archivos[index]),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.white, width: 3),
                                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(17),
                                        // LIMPIEZA: Siempre usar .network para links de Sheets
                                        child: Image.network(
                                          archivos[index],
                                          fit: BoxFit.scaleDown,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const Icon(Icons.broken_image, size: 50),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Positioned(
                                    top: 22,
                                    right: 22,
                                    child: Icon(Icons.zoom_in, color: Colors.black, size: 28),
                                  ),
                                ],
                              ),
                              
                            ),
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
                      Text(data['nombre'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text(data['fecha'] ?? "", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      const Divider(height: 10),
                      Text(data['desc'], style: const TextStyle(fontSize: 17, height: 1.5)),
                      const SizedBox(height: 60),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // 1. Obtenemos la URL de la imagen que está visible actualmente
                        String urlADescargar = archivos[paginaActual];

                        // 2. Llamamos a la función de descarga (Asegúrate de haberla pegado en tu main.dart)
                        descargarImagen(urlADescargar,);
                      },
                      icon: const Icon(Icons.cloud_download),
                      label: const Text("Descargar de la Nube"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, 
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      )
                        )
                  )
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
    

// -- Función para mostrar detalles de un evento (versión más detallada y personalizada)
void _mostrarDetalleEvento(BuildContext context, Map<String, dynamic> evento) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
    builder: (context) => Container(
      child: Column(
        children: [


          // Banner del evento
          Image.network(evento['imagen'], height: 250, width: double.infinity, fit: BoxFit.cover),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(evento['titulo'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  
                  //  Fecha
                  Row(children: [
                    const Icon(Icons.calendar_month, color: Colors.green),
                    const SizedBox(width: 10),
                    Text(evento['fechaTexto'], style: const TextStyle(fontSize: 13)),
                  ]),
                  const SizedBox(height: 8),

                  // Hora
                  Row(children: [
                    const Icon(Icons.access_time, color: Colors.green),
                    const SizedBox(width: 10),
                    Text(evento['horaTexto'], style: const TextStyle(fontSize: 13)),
                  ]),
                  const SizedBox(height: 8),
                  
                  // Fila de Lugar
                  Row(children: [
                    const Icon(Icons.location_on, color: Colors.redAccent),
                    const SizedBox(width: 10),
                    Text(evento['lugar'], style: const TextStyle(fontSize: 13)),
                  ]),
                  
                  const Divider(height: 40),
                  const Text("Información Adicional", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(evento['indicaciones'], style: const TextStyle(fontSize: 16, height: 1.5)),
                  
                  const SizedBox(height: 40),
                  // Botón de acción opcional
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      child: const Text("Entendido"),
                      
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  ); 
}

// --Función auxiliar para el diseño de los botones de las flechas--
Widget _buildBotonNavegacion({required IconData icon, required VoidCallback onPressed}) {
  return Container(
    decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
    child: IconButton(
      icon: Icon(icon, color: Colors.white, size: 20),
      onPressed: onPressed,
    ),
  );
}

// --Función de zoom para una imagen específica (se llama al hacer tap en la imagen del detalle)
class ZoomPage extends StatelessWidget {
  final String assetPath;

  const ZoomPage({super.key, required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // El fondo siempre será negro
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Barra invisible para no tapar
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // Usamos ExtendBodyBehindAppBar para que la imagen use TODA la pantalla
      extendBodyBehindAppBar: true, 
      body: SizedBox.expand( // Obligamos al contenedor a ser del tamaño de la pantalla
        child: InteractiveViewer(
          clipBehavior: Clip.none, // ¡ESTO ES CLAVE! Evita que la imagen se "esconda" al crecer
          panEnabled: true,
          minScale: 1.0, // No permitimos que sea más pequeña que la pantalla
          maxScale: 5.0, // Límite de zoom aumentado
          child: Center(
            child: Image.network(
              assetPath,
              fit: BoxFit.contain, // Mantiene la proporción, pero InteractiveViewer la expandirá
              width: double.infinity,
            ),
          ),
        ),
      ),
    );
  }
}

// -- Función para descargar una imagen desde una URL y guardarla en la galería del dispositivo
Future<void> descargarImagen(String url) async {
  try {
    // 1. Descargar los bytes de la imagen desde Postimages
    final response = await http.get(Uri.parse(url));
    
    // 2. Obtener la carpeta temporal de tu HP/Asus o celular
    final tempDir = await getTemporaryDirectory();
    final path = '${tempDir.path}/evidencia_temp.jpg';
    
    // 3. Crear el archivo físico temporalmente
    final file = File(path);
    await file.writeAsBytes(response.bodyBytes);

    // 4. Guardar en la galería usando GAL
    await Gal.putImage(file.path);
    
    print("Imagen guardada con éxito");
  } catch (e) {
    print("Error al descargar: $e");
  }
}

// -- Función para ordenar eventos por fecha 
List<Map<String, dynamic>> obtenerEventosOrdenados(List<Map<String, dynamic>> listaEventos, {bool ascendente = true}) {
  // Creamos una copia para no alterar la lista original
  List<Map<String, dynamic>> copia = List.from(listaEventos);
  copia.sort((a, b) => ascendente 
    ? a['fecha'].compareTo(b['fecha']) 
    : b['fecha'].compareTo(a['fecha']));
  return copia;
}

// -- Función para obtener solo los eventos futuros (hoy o después)
List<Map<String, dynamic>> obtenerProximosEventos(List<Map<String, dynamic>> listaEventos) {
  DateTime hoy = DateTime.now();
  return listaEventos.where((evento) => evento['fecha'].isAfter(hoy)).toList();
}

// -- Función para reproducir varios tipos de archivos multimedia (imágenes, GIFs, videos) en un visor dedicado
class VisorMultimedia extends StatefulWidget {
  final String path;
  const VisorMultimedia({super.key, required this.path});

  @override
  State<VisorMultimedia> createState() => _VisorMultimediaState();
}
class _VisorMultimediaState extends State<VisorMultimedia> {
  VideoPlayerController? _controller;
  // Detectamos si es video por la extensión o si el link contiene "video/upload" de Cloudinary
  bool get esVideo => widget.path.toLowerCase().contains('.mp4') || 
                      widget.path.toLowerCase().contains('.mov') ||
                      widget.path.contains('video/upload');

  @override
  void initState() {
    super.initState();
    if (esVideo) {
      // CAMBIO CLAVE: Usamos networkUrl para links de internet (Cloudinary)
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.path))
        ..initialize().then((_) {
          setState(() {});
          _controller!.play(); // Opcional: que inicie solo
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
          : const Center(child: CircularProgressIndicator());
    }

    // Para imágenes de Cloudinary/Postimages usamos network
    return InteractiveViewer(
      child: Image.network(
        widget.path, 
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Text("Error al cargar la imagen"),
        ),
      ),
    );
  }

  Widget _buildControlesVideo() {
    return GestureDetector(
      onTap: () => setState(() {
        _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
      }),
      child: Container( // Agregué un container transparente para que sea más fácil tocarlo
        color: Colors.transparent,
        child: Center(
          child: Icon(
            _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white.withOpacity(0.7),
            size: 70,
          ),
        ),
      ),
    );
  }
}

// -- funcion para descargar un video en la galería abriendo el enlace en el navegador
Future<void> _descargarVideo(String url) async {
  // ignore: no_leading_underscores_for_local_identifiers
  final Uri _url = Uri.parse(url);
  if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
    throw Exception('No se pudo abrir el enlace de descarga');
  }
}

class MiniaturaVideo extends StatefulWidget {
  final String videoUrl;
  final BoxFit fit;

  const MiniaturaVideo({Key? key, required this.videoUrl, this.fit = BoxFit.cover}) : super(key: key);

  @override
  _MiniaturaVideoState createState() => _MiniaturaVideoState();
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
        maxWidth: 300, // Ajusta según el tamaño de tu Card
        quality: 75, // Ajusta la calidad para rendimiento
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
        // Mantener el errorBuilder y loadingBuilder de tu código original
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
      );
    } else if (_error) {
      return const Icon(Icons.play_circle_outline, color: Colors.grey, size: 50); // Icono por defecto si falla
    } else {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2)); // Cargando
    }
  }
}