import 'package:flutter/material.dart';
import '../game/arena_game.dart';
import '../components/player.dart';
import '../components/enemy_bot.dart';

class ControlsOverlay extends StatefulWidget {
  final ArenaGame game;
  const ControlsOverlay({required this.game, super.key});

  @override
  State<ControlsOverlay> createState() => _ControlsOverlayState();
}

class _ControlsOverlayState extends State<ControlsOverlay> {
  bool left = false;
  bool right = false;

  @override
  Widget build(BuildContext context) {
    Player? safePlayer;
    EnemyBot? safeEnemy;
    try {
      safePlayer = widget.game.player;
    } catch (_) {
      safePlayer = null;
    }
    try {
      safeEnemy = widget.game.enemy;
    } catch (_) {
      safeEnemy = null;
    }

    return Stack(
      children: [
        Positioned(
          left: 10,
          bottom: 10,
          child: Row(
            children: [
              GestureDetector(
                onTapDown: (_) => setState(() => left = true),
                onTapUp: (_) => setState(() => left = false),
                onTapCancel: () => setState(() => left = false),
                child: Container(
                  width: 70,
                  height: 70,
                  color: left ? Colors.grey[700] : Colors.grey[900],
                  child: const Icon(Icons.arrow_left, color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTapDown: (_) => setState(() => right = true),
                onTapUp: (_) => setState(() => right = false),
                onTapCancel: () => setState(() => right = false),
                child: Container(
                  width: 70,
                  height: 70,
                  color: right ? Colors.grey[700] : Colors.grey[900],
                  child: const Icon(Icons.arrow_right, color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => safePlayer?.jump(),
                child: Container(
                  width: 70,
                  height: 70,
                  color: Colors.blueGrey,
                  child: const Icon(Icons.arrow_upward, color: Colors.white),
                ),
              ),
            ],
          ),
        ),

        Positioned(
          right: 10,
          bottom: 10,
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () => safePlayer != null && safeEnemy != null ? safePlayer.attack(safeEnemy) : null,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Atk'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Heavy'),
              ),
            ],
          ),
        ),

        // HP bars
        Positioned(
          top: 30,
          left: 20,
          child: SizedBox(
            width: 200,
            child: Column(children: [
              _hpBar('Player', safePlayer?.hp ?? 0, safePlayer?.maxHp ?? 100),
              const SizedBox(height: 6),
              _hpBar('Enemy', safeEnemy?.hp ?? 0, safeEnemy?.maxHp ?? 100),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _hpBar(String label, int hp, int maxHp) {
    final pct = hp / maxHp;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label : $hp / $maxHp', style: const TextStyle(color: Colors.white)),
        Container(
          width: 200,
          height: 12,
          decoration: BoxDecoration(border: Border.all(color: Colors.white)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: pct.clamp(0.0, 1.0),
            child: Container(color: Colors.red),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    // periodic movement application
    WidgetsBinding.instance.addPostFrameCallback((_) => _tick());
  }

  void _tick() async {
    while (mounted) {
      final dt = 1 / 60;
      try {
        final p = widget.game.player;
        if (left) p.moveLeft(dt);
        if (right) p.moveRight(dt);
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 16));
      setState(() {});
    }
  }
}
