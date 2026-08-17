import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

import '../components/fighter.dart';
import '../components/player.dart';
import '../components/enemy_bot.dart';

enum GameStatus { playing, victory, defeat }

class ArenaGame extends FlameGame with HasCollisionDetection {
  late Player player;
  late EnemyBot enemy;

  double groundY = 0;
  double arenaLeft = 0;
  double arenaRight = 0;

  /// Exposées à l'UI (ControlsOverlay) pour éviter les rebuilds inutiles :
  /// seule la barre de vie concernée se redessine, pas tout l'overlay.
  final ValueNotifier<double> playerHealth = ValueNotifier<double>(100);
  final ValueNotifier<double> enemyHealth = ValueNotifier<double>(100);
  final ValueNotifier<GameStatus> status =
      ValueNotifier<GameStatus>(GameStatus.playing);

  late Vector2 _playerStart;
  late Vector2 _enemyStart;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    camera.viewfinder.anchor = Anchor.topLeft;

    // Corrige le bug précédent : l'arène était calée sur des coordonnées
    // fixes (800x450) sans rapport avec la taille réelle de l'écran.
    // Ici tout est calculé à partir de `size`, qui correspond à la taille
    // réelle du viewport sur l'appareil.
    arenaLeft = 20;
    arenaRight = size.x - 20;
    groundY = size.y - 70;

    add(RectangleComponent(
      position: Vector2.zero(),
      size: size,
      paint: Paint()..color = const Color(0xFF160F28),
    ));
    add(RectangleComponent(
      position: Vector2(0, groundY + 4),
      size: Vector2(size.x, size.y - groundY),
      paint: Paint()..color = const Color(0xFF3B2A1A),
    ));

    _playerStart = Vector2(size.x * 0.28, groundY);
    _enemyStart = Vector2(size.x * 0.72, groundY);

    player = Player(position: _playerStart.clone());
    enemy = EnemyBot(position: _enemyStart.clone());

    add(player);
    add(enemy);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (status.value != GameStatus.playing) return;

    // Les deux combattants se font toujours face (corrige l'absence totale
    // de direction dans la version précédente).
    player.facingRight = player.position.x <= enemy.position.x;
    enemy.facingRight = enemy.position.x <= player.position.x;

    _resolveAttack(attacker: player, defender: enemy);
    _resolveAttack(attacker: enemy, defender: player);

    playerHealth.value = player.health;
    enemyHealth.value = enemy.health;

    if (enemy.isDead) {
      status.value = GameStatus.victory;
    } else if (player.isDead) {
      status.value = GameStatus.defeat;
    }
  }

  /// Résout un coup au plus une fois par attaque, uniquement si la cible
  /// est à portée ET dans la direction où l'attaquant regarde.
  void _resolveAttack({required Fighter attacker, required Fighter defender}) {
    if (!attacker.isAttacking || attacker.attackResolved) return;

    final distance = (attacker.position.x - defender.position.x).abs();
    final facingCorrectly = attacker.facingRight
        ? defender.position.x >= attacker.position.x
        : defender.position.x <= attacker.position.x;
    final withinRange =
        distance <= Fighter.attackRange + defender.size.x / 2;

    if (withinRange && facingCorrectly) {
      defender.takeDamage(Fighter.attackDamage);
      attacker.attackResolved = true;
      try {
        FlameAudio.play('hit.wav');
      } catch (_) {
        // Pas grave si le fichier son n'est pas encore présent.
      }
    }
  }

  void restart() {
    player.resetTo(_playerStart.clone());
    enemy.resetTo(_enemyStart.clone());
    playerHealth.value = player.health;
    enemyHealth.value = enemy.health;
    status.value = GameStatus.playing;
  }
}