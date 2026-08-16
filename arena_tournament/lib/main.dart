import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/arena_game.dart';
import 'ui/controls.dart';

void main() {
  runApp(const ArenaApp());
}

class ArenaApp extends StatelessWidget {
  const ArenaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final game = ArenaGame();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GameWidget(
          game: game,
          overlayBuilderMap: {
            'Controls': (ctx, game) => ControlsOverlay(game: game as ArenaGame),
          },
          initialActiveOverlays: const ['Controls'],
        ),
      ),
    );
  }
}
