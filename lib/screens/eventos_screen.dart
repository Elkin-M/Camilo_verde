import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:camilo_verde/config/constants.dart';
import 'package:camilo_verde/services/public_content_repository.dart';

class SeccionEventos extends StatefulWidget {
  const SeccionEventos({super.key});

  @override
  State<SeccionEventos> createState() => _SeccionEventosState();
}

class _SeccionEventosState extends State<SeccionEventos> {
  List<Map<String, dynamic>> eventosDinamicos = [];
  bool cargando = true;
  bool _ascendente = true;

  @override
  void initState() {
    super.initState();
    _cargarEventosDeSheets();
  }

  void _ordenarEventos() {
    setState(() {
      _ascendente = !_ascendente;
    });
  }

  Future<void> _cargarEventosDeSheets() async {
    final url = Uri.parse(AppConstants.sheetEventosUrl);

    try {
      final firestoreEvents = await PublicContentRepository().getEvents();
      if (firestoreEvents.isNotEmpty) {
        if (mounted) {
          setState(() {
            eventosDinamicos = firestoreEvents.map((event) => {
              'titulo': event.title,
              'fecha': DateTime.tryParse(event.date) ?? DateTime(2000),
              'fechaTexto': event.dateText,
              'horaTexto': event.time,
              'lugar': event.place,
              'imagen': event.imageUrl,
              'indicaciones': event.instructions,
              'icono': _mapearIcono(event.icon),
            }).toList();
            cargando = false;
          });
        }
        return;
      }
      final respuesta = await http.get(url);
      if (respuesta.statusCode == 200) {
        String tsvTexto = utf8.decode(respuesta.bodyBytes);
        List<String> lineas = tsvTexto.split('\n');
        List<Map<String, dynamic>> temporal = [];

        for (int i = 1; i < lineas.length; i++) {
          if (lineas[i].trim().isEmpty) continue;
          List<String> celdas = lineas[i].split('\t');

          if (celdas.length >= 8) {
            DateTime? fechaParsed;
            try {
              fechaParsed = DateTime.parse(celdas[1].trim());
            } catch (_) {
              fechaParsed = DateTime(2000);
            }

            temporal.add({
              'titulo': celdas[0].trim(),
              'fecha': fechaParsed,
              'fechaTexto': celdas[2].trim(),
              'horaTexto': celdas[3].trim(),
              'lugar': celdas[4].trim(),
              'imagen': celdas[5].trim(),
              'indicaciones': celdas[6].trim(),
              'icono': _mapearIcono(celdas[7].trim()),
            });
          }
        }

        if (mounted) {
          setState(() {
            eventosDinamicos = temporal;
            cargando = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error cargando eventos: $e");
      if (mounted) setState(() => cargando = false);
    }
  }

  IconData _mapearIcono(String nombreIcono) {
    switch (nombreIcono.toLowerCase()) {
      case 'recycling':
        return Icons.recycling;
      case 'forest':
        return Icons.forest;
      case 'school':
        return Icons.school;
      default:
        return Icons.event;
    }
  }

  void _mostrarDetalleEvento(BuildContext context, Map<String, dynamic> evento) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.85,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              child: Image.network(
                evento['imagen'],
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 220,
                  color: Colors.green[100],
                  child: const Icon(Icons.event, size: 80, color: Colors.green),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      evento['titulo'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month, color: Colors.green),
                        const SizedBox(width: 10),
                        Text(evento['fechaTexto'],
                            style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.green),
                        const SizedBox(width: 10),
                        Text(evento['horaTexto'],
                            style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.redAccent),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(evento['lugar'],
                              style: const TextStyle(fontSize: 14)),
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                    const Text(
                      "Información Adicional",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      evento['indicaciones'],
                      style: const TextStyle(fontSize: 15, height: 1.4),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[800],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Entendido"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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

    if (eventosDinamicos.isEmpty) {
      return const Center(child: Text("No hay eventos programados"));
    }

    DateTime ahora = DateTime.now();

    List<Map<String, dynamic>> futuros = eventosDinamicos
        .where((evento) =>
            evento['fecha'].isAfter(ahora) ||
            evento['fecha'].isAtSameMomentAs(ahora))
        .toList();

    List<Map<String, dynamic>> pasados = eventosDinamicos
        .where((evento) => evento['fecha'].isBefore(ahora))
        .toList();

    futuros.sort((a, b) => _ascendente
        ? a['fecha'].compareTo(b['fecha'])
        : b['fecha'].compareTo(a['fecha']));
    pasados.sort((a, b) => _ascendente
        ? a['fecha'].compareTo(b['fecha'])
        : b['fecha'].compareTo(a['fecha']));

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
                const Text(
                  "Eventos",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _ordenarEventos,
                  icon: Icon(
                    _ascendente ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 18,
                    color: Colors.green[800],
                  ),
                  label: Text(
                    _ascendente ? "Cercano - Lejano" : "Lejano - Cercano",
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
              onRefresh: _cargarEventosDeSheets,
              color: Colors.green,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                itemCount: listaFinal.length,
                itemBuilder: (context, index) {
                  final evento = listaFinal[index];
                  bool esPasado = evento['fecha'].isBefore(ahora);
                  bool mostrarTituloPasados = esPasado &&
                      (index == 0 ||
                          !listaFinal[index - 1]['fecha'].isBefore(ahora));

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (mostrarTituloPasados)
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 5),
                          child: Text(
                            "🕒 Eventos Pasados",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      Opacity(
                        opacity: esPasado ? 0.6 : 1.0,
                        child: _buildEventoCardCompleta(
                            context, evento, esPasado),
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

  Widget _buildEventoCardCompleta(
      BuildContext context, Map<String, dynamic> evento, bool esPasado) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => _mostrarDetalleEvento(context, evento),
        child: Column(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                evento['imagen'],
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    esPasado ? Colors.grey[300] : Colors.green[100],
                child: Icon(
                  evento['icono'],
                  color: esPasado ? Colors.grey : Colors.green[800],
                ),
              ),
              title: Text(
                evento['titulo'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: esPasado ? Colors.grey : Colors.black87,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(evento['fechaTexto']),
                  if (esPasado)
                    const Text(
                      "⚠️ Este evento ya finalizó",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
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
