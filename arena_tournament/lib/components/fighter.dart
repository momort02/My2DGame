import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

import '../game/arena_game.dart';

/// Classe de base d'un combattant (joueur ou bot).
///
/// Centralise la physique (gravité, saut), l'attaque (cooldown, durée) et
/// les dégâts. Corrige les bugs de la version précédente :
/// - plus de cast `dynamic` fragile pour appliquer les dégâts ;
/// - toute attaque respecte désormais un cooldown (avant : le bot infligeait
///   des dégâts à CHAQUE frame tant qu'il était à portée).
class Fighter extends PositionComponent
    with HasGameRef<ArenaGame>, CollisionCallbacks {
  Fighter({
    required Vector2 position,
    required this.color,
    this.maxHealth = 100,
  })  : health = maxHealth,
        super(
          position: position,
          size: Vector2(56, 100),
          anchor: Anchor.bottomCenter,
        );

  // Constantes de gameplay (communes joueur/bot, faciles à ajuster).
  static const double gravity = 1400;
  static const double jumpSpeed = -560;
  static const double moveSpeed = 220;
  static const double attackDuration = 0.22;
  static const double attackCooldownTime = 0.5;
  static const double attackRange = 78;
  static const double attackDamage = 8;

  final Color color;
  final double maxHealth;
  double health;

  double velocityY = 0;
  bool onGround = true;
  bool facingRight = true;

  /// -1 = gauche, 0 = arrêt, 1 = droite.
  int moveDir = 0;

  bool isAttacking = false;
  double attackTimer = 0;
  double attackCooldown = 0;

  /// Passe à true une fois que le coup en cours a été résolu (dégâts
  /// appliqués ou non), pour ne jamais infliger de dégâts deux fois pour
  /// une seule attaque.
  bool attackResolved = true;

  bool get isDead => health <= 0;

  late final RectangleComponent _body;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
    _body = RectangleComponent(size: size, paint: Paint()..color = color);
    add(_body);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Déplacement horizontal, borné aux limites de l'arène.
    position.x += moveDir * moveSpeed * dt;
    position.x = position.x.clamp(
      gameRef.arenaLeft + size.x / 2,
      gameRef.arenaRight - size.x / 2,
    );

    // Gravité simple.
    velocityY += gravity * dt;
    position.y += velocityY * dt;
    if (position.y >= gameRef.groundY) {
      position.y = gameRef.groundY;
      velocityY = 0;
      onGround = true;
    }

    if (attackCooldown > 0) {
      attackCooldown -= dt;
    }
    if (isAttacking) {
      attackTimer -= dt;
      if (attackTimer <= 0) isAttacking = false;
    }

    _body.paint.color = isAttacking ? Colors.white : color;
    // Flip visuel selon la direction du regard. Appliqué sur le composant
    // parent (ancré au centre en bas) plutôt que sur `_body` directement :
    // flipper un enfant ancré en haut-à-gauche le décale hors du parent.
    scale.x = facingRight ? 1 : -1;
  }

  void jump() {
    if (onGround) {
      velocityY = jumpSpeed;
      onGround = false;
      try {
        FlameAudio.play('jump.wav');
      } catch (_) {
        // Pas grave si le fichier son n'est pas encore présent.
      }
    }
  }

  /// Démarre une attaque si le cooldown est écoulé. Ne fait rien sinon
  /// (corrige le spam illimité du bouton d'attaque).
  void startAttack() {
    if (attackCooldown <= 0 && !isAttacking) {
      isAttacking = true;
      attackResolved = false;
      attackTimer = attackDuration;
      attackCooldown = attackCooldownTime;
    }
  }

  void takeDamage(double amount) {
    health = (health - amount).clamp(0, maxHealth);
  }

  void resetTo(Vector2 startPosition) {
    position = startPosition;
    velocityY = 0;
    onGround = true;
    moveDir = 0;
    isAttacking = false;
    attackCooldown = 0;
    attackResolved = true;
    health = maxHealth;
  }
}