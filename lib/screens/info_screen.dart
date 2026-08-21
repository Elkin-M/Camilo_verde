import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:camilo_verde/config/constants.dart';

class SeccionInfo extends StatelessWidget {
  const SeccionInfo({super.key});

  Future<void> _abrirEnlace(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('No se pudo abrir $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        _buildSeccionTitulo("¿Quiénes somos?"),
        const SizedBox(height: 10),
        _buildCuadroDeTextobold("El PRAE CAMILO VERDE pertenece a la:"),
        const SizedBox(height: 10),
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/camilotorreslogo.png',
              width: 250,
              height: 250,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildCuadroDeTexto2("Aprobada por las Resoluciones:"),
        const SizedBox(height: 5),
        _buildCuadroDeTexto2("Nº 0846 de mayo 30 de 2002"),
        _buildCuadroDeTexto2("Nº 0364 de diciembre de 2001"),
        _buildCuadroDeTexto2("Nº 1259 de junio 17 de 1998"),
        _buildCuadroDeTexto2("N° 1071 de 18 de 2004"),
        _buildCuadroDeTexto2("Código del ICFES: 096446"),
        _buildCuadroDeTexto2("Código DANE: 113001000771"),
        _buildCuadroDeTexto2("NIT: 806003674-1"),
        const SizedBox(height: 18),
        _buildCuadroDeTexto(
          "Somos una institución educativa de carácter oficial ubicada en el barrio El Pozón de la ciudad de Cartagena de Indias.",
        ),
        const SizedBox(height: 10),
        _buildCuadroDeTexto(
          "Ofrecemos el servicio educativo en los niveles de preescolar, básica primaria, básica secundaria y nocturna.",
        ),
        const SizedBox(height: 35),

        // Botón Misión
        ElevatedButton(
          onPressed: () => _mostrarMision(context),
          style: _estiloBotonPrincipal(),
          child: const Text("Nuestra Misión"),
        ),
        const SizedBox(height: 15),

        // Botón Visión
        ElevatedButton(
          onPressed: () => _mostrarVision(context),
          style: _estiloBotonPrincipal(),
          child: const Text("Nuestra Visión"),
        ),
        const SizedBox(height: 15),

        // Botón FAQ
        ElevatedButton(
          onPressed: () => _mostrarFAQ(context),
          style: _estiloBotonPrincipal(),
          child: const Text("Preguntas Frecuentes (FAQ)"),
        ),
        const SizedBox(height: 40),

        // Sección Contacto
        _buildSeccionTitulo("Contáctanos"),
        const SizedBox(height: 10),
        _buildCuadroDeTexto("Contamos con dos sedes:"),
        const SizedBox(height: 15),
        _buildSeccionTitulo2("• Sede Principal:"),
        _buildCuadroDeTextobold("Camilo Torres del Pozón"),
        _buildCuadroDeTexto("Dirección: EL POZÓN - Mz. 49, Lote 13, Cr. 89"),
        const SizedBox(height: 15),
        _buildSeccionTitulo2("• Sede de Primaria:"),
        _buildCuadroDeTextobold(
            "Nuevo Horizonte - Escuela Distrital Los Chulianes"),
        _buildCuadroDeTexto("Dirección: EL POZÓN - Tv. 56, #87-46"),
        _buildCuadroDeTexto("DANE: 113001000275"),
        const SizedBox(height: 30),

        _buildCuadroDeTexto("Más formas de contactarnos:"),
        const SizedBox(height: 15),

        _buildSeccionTitulo2("• Página Web:"),
        const SizedBox(height: 5),
        RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black, fontSize: 15),
            children: [
              const TextSpan(text: "Sitio oficial: "),
              TextSpan(
                text: "iectp.edu.co",
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => _abrirEnlace(AppConstants.webOficialUrl),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        _buildSeccionTitulo2("• Redes Sociales:"),
        const SizedBox(height: 5),
        RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black, fontSize: 15),
            children: [
              const TextSpan(text: "Instagram: "),
              TextSpan(
                text: "@ie_camilotorres",
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => _abrirEnlace(AppConstants.instagramUrl),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black, fontSize: 15),
            children: [
              const TextSpan(text: "Facebook: "),
              TextSpan(
                text: "@IEOCAMILOTRRES",
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => _abrirEnlace(AppConstants.facebookUrl),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black, fontSize: 15),
            children: [
              const TextSpan(text: "Radio Escolar: "),
              TextSpan(
                text: "@Onda-Camilista",
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => _abrirEnlace(AppConstants.facebookRadioUrl),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  void _mostrarMision(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "NUESTRA MISIÓN",
                textAlign: TextAlign.center,
                style: GoogleFonts.unbounded(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
              const SizedBox(height: 15),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset('assets/images/colegio.jpg',
                    fit: BoxFit.cover, height: 180, width: double.infinity),
              ),
              const SizedBox(height: 20),
              const Text(
                "Somos una Institución Educativa de carácter oficial, que brinda a sus estudiantes una formación integral, fundamentada en la convivencia democrática, el pensamiento crítico, científico y tecnológico; que les permita satisfacer sus necesidades y las de su contexto.",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: _estiloBotonPrincipal(),
                child: const Text("Entendido"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _mostrarVision(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "NUESTRA VISIÓN",
                textAlign: TextAlign.center,
                style: GoogleFonts.unbounded(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
              const SizedBox(height: 15),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset('assets/images/camilotorres.jpg',
                    fit: BoxFit.cover, height: 180, width: double.infinity),
              ),
              const SizedBox(height: 20),
              const Text(
                "Seremos en el 2026 una institución Educativa reconocida por su compromiso con el desarrollo integral de los estudiantes y las competencias necesarias para contribuir en la transformación social.",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: _estiloBotonPrincipal(),
                child: const Text("Entendido"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _mostrarFAQ(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                controller: scrollController,
                children: [
                  Text(
                    "PREGUNTAS FRECUENTES (FAQ)",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.unbounded(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[900],
                    ),
                  ),
                  const SizedBox(height: 15),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset('assets/images/colegio.jpg',
                        fit: BoxFit.cover, height: 160, width: double.infinity),
                  ),
                  const SizedBox(height: 20),
                  _buildFAQTile(
                    "¿Qué es PRAE CAMILO VERDE?",
                    "★ 'CAMILO VERDE' es nuestro Proyecto Ambiental Escolar (PRAE).",
                  ),
                  _buildFAQTile(
                    "¿Cuál es el propósito de Camilo Verde?",
                    "★ CAMILO VERDE busca integrar la dimensión ambiental en toda la vida del colegio, fomentando una cultura de sostenibilidad en toda la comunidad Camilista.",
                  ),
                  _buildFAQTile(
                    "¿Por qué Camilo Verde?",
                    "★ Como institución educativa, tenemos el deber de formar ciudadanos conscientes y activos en el cuidado del medio ambiente. Transformamos el colegio en un 'Laboratorio vivo de sostenibilidad', donde aprendemos en la práctica.",
                  ),
                  _buildFAQTile(
                    "¿Cuál ha sido el impacto del proyecto?",
                    "★ Esta iniciativa ha repercutido en la comunidad Camilista e incluso en el barrio El Pozón, brindando a los estudiantes y familias una vía segura para aprender y aplicar sus conocimientos ambientales.",
                  ),
                  _buildFAQTile(
                    "¿Quiénes lo dirigen?",
                    "★ Adelis Herrera - Docente\n★ Emma Moreno - Docente\n★ Euclides de las Aguas - Rector",
                  ),
                  _buildFAQTile(
                    "¿Qué es una Recogetón?",
                    "★ Una Recogetón es una actividad de recolección de residuos sólidos en el área escolar para promover la conciencia ambiental y la responsabilidad ciudadana.",
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: _estiloBotonPrincipal(),
                    child: const Text("Entendido"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFAQTile(String pregunta, String respuesta) {
    return ExpansionTile(
      textColor: const Color(0xFF2E7D32),
      collapsedTextColor: Colors.black87,
      iconColor: const Color(0xFF2E7D32),
      collapsedIconColor: Colors.green,
      title: Text(
        pregunta,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            respuesta,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
        ),
      ],
    );
  }

  ButtonStyle _estiloBotonPrincipal() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.green[800],
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 4,
    );
  }

  Widget _buildSeccionTitulo(String titulo) {
    return Text(
      titulo,
      style: GoogleFonts.unbounded(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.green[800],
        decoration: TextDecoration.underline,
        decorationColor: Colors.green[800],
      ),
    );
  }

  Widget _buildSeccionTitulo2(String titulo) {
    return Text(
      titulo,
      style: GoogleFonts.unbounded(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.green[800],
      ),
    );
  }

  Widget _buildCuadroDeTexto(String texto) {
    return Text(
      texto,
      style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
    );
  }

  Widget _buildCuadroDeTexto2(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(255, 100, 100, 100),
      ),
    );
  }

  Widget _buildCuadroDeTextobold(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }
}
