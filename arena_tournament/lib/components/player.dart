import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';

class Player extends PositionComponent with HasGameRef, CollisionCallbacks {
  Vector2 velocity = Vector2.zero();
  bool onGround = false;
  double speed = 200;
  double jumpSpeed = -420;
  int maxHp = 100;
  int hp = 100;

  // simple placeholder "animation" using color frames
  final List<Color> _frames = [Colors.blue, Colors.lightBlue, Colors.blueAccent];
  double _frameTimer = 0;
  int _frameIndex = 0;

  Player() : super(size: Vector2(50, 80));

  late RectangleComponent _body;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
    _body = RectangleComponent(size: size, paint: Paint()..color = _frames[0]);
    add(_body);
  }

  @override
  void update(double dt) {
    velocity.y += 1000 * dt; // gravity
    position += velocity * dt;

    if (position.y >= 320) {
      position.y = 320;
      velocity.y = 0;
      onGround = true;
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

  void moveLeft(double dt) {
    position.x -= speed * dt;
  }

  void moveRight(double dt) {
    position.x += speed * dt;
  }

  void jump() {
    if (onGround) {
      velocity.y = jumpSpeed;
      onGround = false;
      // play jump sound if available
      try {
        FlameAudio.play('jump.wav');
      } catch (_) {}
    }
  }

  void attack(PositionComponent? target) {
    // simple melee: if target in range, reduce hp
    if (target != null) {
      final dist = (target.position - position).length;
      if (dist < 80) {
        // assume target has hp field
        try {
          final t = target as dynamic;
          t.hp = (t.hp - 15).clamp(0, t.maxHp) as int;
          FlameAudio.play('hit.wav');
        } catch (_) {}
      }
    }
  }
}
