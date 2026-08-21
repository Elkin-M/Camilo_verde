import 'package:camilo_verde/game/camilo_game.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class JuegoScreen extends StatelessWidget {
  const JuegoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camilo Runner'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: GameWidget(
        game: CamiloGame(),
      ),
    );
  }
}
