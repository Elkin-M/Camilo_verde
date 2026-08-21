import 'dart:async';
import 'package:camilo_verde/game/world_level.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class CamiloGame extends FlameGame with HasCollisionDetection {
  static Vector2 sceneSize = Vector2(480, 220);
  late CameraComponent cameraComponent;
  late WorldLevel worldLevel;

  @override
  Future<void> onLoad() async {
    images.prefix = 'assets/camilorunner/';
    worldLevel = WorldLevel();
    cameraComponent = CameraComponent.withFixedResolution(
      world: worldLevel,
      width: sceneSize.x,
      height: sceneSize.y,
    );

    addAll([cameraComponent, worldLevel]);
  }
}
