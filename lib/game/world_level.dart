import 'dart:async';
import 'package:camilo_verde/game/camilo_game.dart';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';

class WorldLevel extends World {
  @override
  Future<void> onLoad() async {
    add(await loadParallaxComponent());
  }

  Future<ParallaxComponent> loadParallaxComponent() async {
    return ParallaxComponent.load(
      [
        ParallaxImageData('Sprites/Game Objects/Background.png'),
        ParallaxImageData('Sprites/Game Objects/Foreground.png'),
      ],
      baseVelocity: Vector2(50, 0),
      velocityMultiplierDelta: Vector2(1.5, 1),
      size: CamiloGame.sceneSize,
    );
  }
}
