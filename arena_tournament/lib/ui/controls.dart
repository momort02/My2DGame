import 'package:flutter/material.dart';

import '../game/arena_game.dart';

class ControlsOverlay extends StatelessWidget {
  final ArenaGame game;
  const ControlsOverlay({required this.game, super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // --- Barres de vie : toujours visibles ---
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Expanded(
                  child: _HealthBar(
                    label: 'JOUEUR',
                    notifier: game.playerHealth,
                    color: const Color(0xFF31E6D8),
                    alignEnd: false,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _HealthBar(
                    label: 'BOT',
                    notifier: game.enemyHealth,
                    color: const Color(0xFFFF4D8D),
                    alignEnd: true,
                  ),
                ),
              ],
            ),
          ),

          // --- Déplacement / saut : toujours visibles ---
          Positioned(
            left: 10,
            bottom: 24,
            child: Row(
              children: [
                _HoldButton(
                  icon: Icons.arrow_left,
                  onPressStart: () => game.player.moveDir = -1,
                  onPressEnd: () {
                    if (game.player.moveDir == -1) game.player.moveDir = 0;
                  },
                ),
                const SizedBox(width: 10),
                _HoldButton(
                  icon: Icons.arrow_right,
                  onPressStart: () => game.player.moveDir = 1,
                  onPressEnd: () {
                    if (game.player.moveDir == 1) game.player.moveDir = 0;
                  },
                ),
                const SizedBox(width: 10),
                _HoldButton(
                  icon: Icons.arrow_upward,
                  color: Colors.blueGrey,
                  onPressStart: () => game.player.jump(),
                ),
              ],
            ),
          ),

          // --- Attaques : toujours visibles ---
          Positioned(
            right: 10,
            bottom: 24,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () => game.player.startAttack(),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Attaque'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.withValues(alpha: 0.35),
                  ),
                  child: const Text('Lourde (bientôt)'),
                ),
              ],
            ),
          ),

          // --- Écran de fin : SEUL ce bloc est conditionnel ---
          ValueListenableBuilder<GameStatus>(
            valueListenable: game.status,
            builder: (context, status, _) {
              if (status == GameStatus.playing) {
                return const SizedBox.shrink();
              }
              final won = status == GameStatus.victory;
              return Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.7),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          won ? 'VICTOIRE !' : 'DÉFAITE',
                          style: TextStyle(
                            color: won ? Colors.greenAccent : Colors.redAccent,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: game.restart,
                          child: const Text('Rejouer'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HealthBar extends StatelessWidget {
  const _HealthBar({
    required this.label,
    required this.notifier,
    required this.color,
    required this.alignEnd,
  });

  final String label;
  final ValueNotifier<double> notifier;
  final Color color;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        const SizedBox(height: 4),
        ValueListenableBuilder<double>(
          valueListenable: notifier,
          builder: (context, health, _) {
            final pct = (health / 100).clamp(0.0, 1.0);
            return Container(
              height: 12,
              decoration: BoxDecoration(border: Border.all(color: Colors.white)),
              child: Align(
                alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: pct,
                  child: Container(color: color),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _HoldButton extends StatelessWidget {
  const _HoldButton({
    required this.icon,
    required this.onPressStart,
    this.onPressEnd,
    this.color,
  });

  final IconData icon;
  final VoidCallback onPressStart;
  final VoidCallback? onPressEnd;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => onPressStart(),
      onTapUp: (_) => onPressEnd?.call(),
      onTapCancel: () => onPressEnd?.call(),
      child: Container(
        width: 70,
        height: 70,
        color: color ?? Colors.grey[900],
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}