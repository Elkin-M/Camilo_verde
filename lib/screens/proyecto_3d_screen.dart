import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class Proyecto3dScreen extends StatelessWidget {
  const Proyecto3dScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Proyecto 3D',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
            Chip(
              label: const Text('Próximo'),
              backgroundColor: Colors.orange[100],
              side: BorderSide.none,
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Modelo 3D de nuestro Ecopunto Camilista',
          style: TextStyle(fontSize: 15),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 320,
          child: ModelViewer(
            src: 'assets/models/ecopunto_camilista.glb',
            alt: 'Modelo 3D del Ecopunto Camilista',
            autoRotate: true,
            cameraControls: true,
            ar: false,
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 18),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Padding(
            padding: EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Qué es este proyecto?',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Estamos trabajando en un modelo 3D interactivo para mostrar nuestro futuro Ecopunto Camilista, un espacio para reciclar, aprender y cuidar el planeta.',
                  style: TextStyle(height: 1.5),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.orange[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.schedule, size: 20),
              SizedBox(width: 10),
              Text('Muy pronto más información'),
            ],
          ),
        ),
      ],
    );
  }
}
