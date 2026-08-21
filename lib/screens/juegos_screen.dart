import 'package:flutter/material.dart';
import 'package:camilo_verde/screens/juego_screen.dart';

class JuegosScreen extends StatelessWidget {
  const JuegosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: [
        const Text(
          'Aprende y diviértete cuidando nuestro planeta 🌍',
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 18),
        Card(
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/juegos_botellas.png',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reto del Reciclaje',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Clasifica correctamente los residuos y gana puntos.',
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const JuegoScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Jugar ahora'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[800],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'Más juegos',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _JuegoItem(
          icon: Icons.eco,
          title: 'Memorama Ambiental',
          description: 'Encuentra las parejas y aprende.',
        ),
        _JuegoItem(
          icon: Icons.grid_3x3,
          title: 'Sopa Camilista',
          description: 'Encuentra palabras sobre el medio ambiente.',
        ),
        _JuegoItem(
          icon: Icons.quiz,
          title: 'Trivia Verde',
          description: 'Pon a prueba tus conocimientos ambientales.',
        ),
      ],
    );
  }
}

class _JuegoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _JuegoItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: Icon(icon, color: Colors.green[800]),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Chip(label: Text('Próximo')),
      ),
    );
  }
}
