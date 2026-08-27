import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:camilo_verde/game/world_level.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class CamiloGame extends FlameGame with HasCollisionDetection {
  static Vector2 sceneSize = Vector2(480, 270);
  static double get groundY => sceneSize.y - 86;
  late CameraComponent cameraComponent;
  late WorldLevel worldLevel;
  late RunnerPlayer player;
  late RunnerObstacle obstacle;
  int score = 0;
  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);
  bool gameOver = false;

  @override
  Future<void> onLoad() async {
    images.prefix = 'assets/camilorunner/';
    worldLevel = WorldLevel();
    cameraComponent = CameraComponent.withFixedResolution(
      world: worldLevel,
      width: sceneSize.x,
      height: sceneSize.y,
    );
    cameraComponent.viewfinder.position = sceneSize / 2;

    player = RunnerPlayer()
      ..position = Vector2(70, groundY)
      ..priority = 10
      ..size = Vector2.all(42);
    obstacle = RunnerObstacle()
      ..position = Vector2(390, groundY + 20)
      ..priority = 10
      ..size = Vector2(28, 38);
    worldLevel.addAll([player, obstacle]);
    addAll([cameraComponent, worldLevel]);
  }

  void jump() {
    if (gameOver) {
      restart();
      return;
    }
    player.jump();
  }

  void restart() {
    score = 0;
    scoreNotifier.value = 0;
    gameOver = false;
    player.reset();
    obstacle.reset();
  }
}

class RunnerPlayer extends SpriteAnimationComponent with HasGameReference<CamiloGame> {
  double verticalSpeed = 0;
  bool onGround = true;

  @override
  Future<void> onLoad() async {
    animation = await SpriteAnimation.load(
      'Animations/Run.png',
      SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.12,
        textureSize: Vector2.all(32),
      ),
    );
  }

  void jump() {
    if (!onGround) return;
    verticalSpeed = -330;
    onGround = false;
  }

  void reset() {
    position = Vector2(70, CamiloGame.groundY);
    verticalSpeed = 0;
    onGround = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    verticalSpeed += 800 * dt;
    position.y += verticalSpeed * dt;
    if (position.y >= CamiloGame.groundY) {
      position.y = CamiloGame.groundY;
      verticalSpeed = 0;
      onGround = true;
    }
  }
}

class RunnerObstacle extends SpriteComponent with HasGameReference<CamiloGame> {
  double speed = 150;
  bool counted = false;

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('Sprites/Game Objects/Obstacle_1.png');
  }

  void reset() {
    position = Vector2(390, CamiloGame.groundY + 20);
    counted = false;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.gameOver) return;
    position.x -= speed * dt;
    if (!counted && position.x + width < game.player.x) {
      counted = true;
      game.score++;
      game.scoreNotifier.value = game.score;
    }
    if (position.x + width < 0) reset();
    final playerBox = game.player.toRect();
    final obstacleBox = toRect();
    if (playerBox.overlaps(obstacleBox)) game.gameOver = true;
  }
}
