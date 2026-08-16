import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

import 'player.dart';

class EnemyBot extends PositionComponent with HasGameRef, CollisionCallbacks {
  final Player playerRef;
  Vector2 velocity = Vector2.zero();
  double speed = 120;
  int maxHp = 100;
  int hp = 100;

  // placeholder animation colors
  final List<Color> _frames = [Colors.red, Colors.orange, Colors.deepOrange];
  double _frameTimer = 0;
  int _frameIndex = 0;

  late RectangleComponent _body;

  EnemyBot(this.playerRef) : super(size: Vector2(50, 80));

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
    _body = RectangleComponent(size: size, paint: Paint()..color = _frames[0]);
    add(_body);
  }

  @override
  void update(double dt) {
    // simple AI: move toward player if far, else attack
    final dir = (playerRef.position - position);
    if (dir.x.abs() > 70) {
      position.x += speed * dt * (dir.x.sign);
    } else {
      // attack
      if ((playerRef.position - position).length < 80) {
        playerRef.hp = (playerRef.hp - 8).clamp(0, playerRef.maxHp) as int;
        try {
          FlameAudio.play('hit.wav');
        } catch (_) {}
      }
    }

    // update placeholder animation
    _frameTimer += dt;
    if (_frameTimer > 0.12) {
      _frameTimer = 0;
      _frameIndex = (_frameIndex + 1) % _frames.length;
      _body.paint.color = _frames[_frameIndex];
    }

    super.update(dt);
  }
}
