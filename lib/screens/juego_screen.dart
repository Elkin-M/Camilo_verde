import 'package:camilo_verde/game/camilo_game.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class JuegoScreen extends StatelessWidget {
  const JuegoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = CamiloGame();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camilo Runner'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: const Color(0xFFB7E4F5),
            child: GameWidget(game: game),
          ),
          Positioned(
            top: 14,
            left: 16,
            right: 16,
            child: ValueListenableBuilder<int>(
              valueListenable: game.scoreNotifier,
              builder: (context, score, child) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _HudLabel(text: 'Puntos: $score'),
                  _HudLabel(text: game.gameOver ? 'Toca saltar para reiniciar' : 'Toca SALTAR'),
                ],
              ),
            ),
          ),
          Positioned(
            right: 18,
            bottom: 22,
            child: FloatingActionButton.extended(
              onPressed: game.jump,
              icon: const Icon(Icons.arrow_upward),
              label: const Text('Saltar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _HudLabel extends StatelessWidget {
  const _HudLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(10)),
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      );
}

