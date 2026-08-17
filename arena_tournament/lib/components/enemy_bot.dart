import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'fighter.dart';

/// Bot ennemi très simple pour le mode Entraînement.
///
/// Avant : infligeait des dégâts à chaque frame dès qu'il était à portée
/// du joueur (donc ~60 fois par seconde), ce qui tuait le joueur quasi
/// instantanément. Corrigé : le bot déclenche `startAttack()`, qui respecte
/// désormais le cooldown défini dans [Fighter] — un seul coup toutes les
/// ~0.5s, comme le joueur.
class EnemyBot extends Fighter {
  EnemyBot({required Vector2 position})
      : super(position: position, color: const Color(0xFFFF4D8D));

  final Random _random = Random();
  double _decisionTimer = 0;

  static const double _engageDistance = 95;
  static const double _decisionInterval = 0.25;

  @override
  void update(double dt) {
    _decisionTimer -= dt;
    if (_decisionTimer <= 0) {
      _decisionTimer = _decisionInterval;
      _decide();
    }
    super.update(dt);
  }

  void _decide() {
    final player = gameRef.player;
    final distance = (position.x - player.position.x).abs();

    if (distance > _engageDistance) {
      moveDir = position.x < player.position.x ? 1 : -1;
    } else {
      moveDir = 0;
      if (attackCooldown <= 0) {
        startAttack();
      }
    }

    if (onGround && _random.nextDouble() < 0.06) {
      jump();
    }
  }
}