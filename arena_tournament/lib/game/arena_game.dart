import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../components/player.dart';
import '../components/enemy_bot.dart';

class ArenaGame extends FlameGame with HasCollisionDetection {
  late Player player;
  late EnemyBot enemy;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Ne pas forcer de viewport spécifique ici pour garder compatibilité
    // avec différentes versions de Flame. Utiliser le viewport par défaut.

    // Add floor
    add(RectangleComponent(
      position: Vector2(0, 400),
      size: Vector2(800, 50),
      paint: Paint()..color = Colors.brown,
    ));

    // Player
    player = Player()
      ..position = Vector2(100, 300);
    add(player);

    // Enemy bot
    enemy = EnemyBot(player)
      ..position = Vector2(600, 300);
    add(enemy);
  }

  void onPlayerAttack() {
    // placeholder for hit detection
  }
}
