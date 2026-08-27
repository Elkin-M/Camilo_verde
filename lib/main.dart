import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camilo_verde/screens/inicio_screen.dart';
import 'package:camilo_verde/screens/galeria_screen.dart';
import 'package:camilo_verde/screens/info_screen.dart';
import 'package:camilo_verde/screens/eventos_screen.dart';
import 'package:camilo_verde/screens/juego_screen.dart';
import 'package:camilo_verde/screens/juegos_screen.dart';
import 'package:camilo_verde/screens/proyecto_3d_screen.dart';
import 'package:camilo_verde/screens/admin_screen.dart';
import 'package:camilo_verde/services/firebase_backend.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseBackend.initialize();
  runApp(const CamiloVerdeApp());
}

class CamiloVerdeApp extends StatelessWidget {
  const CamiloVerdeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CAMILO VERDE',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          primary: const Color(0xFF2E7D32),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.unboundedTextTheme(),
      ),
      home: const PantallaPrincipal(),
    );
  }
}

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _indiceActual = 0;
  int _contadorHuevoPascua = 0;

  final List<Widget> _paginas = const [
    SeccionInicio(),
    JuegosScreen(),
    SeccionGaleria(),
    SeccionEventos(),
    SeccionInfo(),
    Proyecto3dScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 82,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            // Easter Egg: Tocar 3 veces el logo abre el juego Camilo Runner
            GestureDetector(
              onTap: () {
                _contadorHuevoPascua++;
                if (_contadorHuevoPascua == 3) {
                  _contadorHuevoPascua = 0;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const JuegoScreen(),
                    ),
                  );
                }
              },
              child: Image.asset(
                'assets/images/camiloverdefulllogo.png',
                height: 76,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Nosotros',
            icon: const Icon(Icons.info_outline),
            onPressed: () => setState(() => _indiceActual = 4),
          ),
          IconButton(
            tooltip: 'Administración',
            icon: const Icon(Icons.lock_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminScreen()),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fondo1.jpg'),
            fit: BoxFit.cover,
            opacity: 0.15,
          ),
        ),
        child: _paginas[_indiceActual],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceActual == 5 ? 4 : _indiceActual,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 10,
        unselectedFontSize: 9,
        iconSize: 21,
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _indiceActual = index == 4 ? 5 : index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports),
            label: 'Juegos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Galería',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Eventos'),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_in_ar),
            label: 'Próximo',
          ),
        ],
      ),
    );
  }
}
