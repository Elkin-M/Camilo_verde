import 'dart:async';
import 'package:camilo_verde/worlds/world_level.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(GameWidget(
    game: MyGame(),
  ));
}
class MyGame extends FlameGame with HasCollisionDetection {
  static Vector2 sceneSize = Vector2(480, 220);
  late CameraComponent cameraComponent;
  late WorldLevel worldLevel;

  @override
  Future<void> onLoad() async{
    worldLevel = WorldLevel();
    cameraComponent = CameraComponent.withFixedResolution(
      world: worldLevel,
      width: sceneSize.x,
       height: sceneSize.y,
       );

  addAll([cameraComponent, worldLevel]);

  }
}