import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'game/arena_game.dart';
import 'ui/controls.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Jeu de combat 1v1 pensé pour être joué en paysage.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
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
        body: Stack(
          children: [
            GameWidget<ArenaGame>(game: game),
            ControlsOverlay(game: game),
          ],
        ),
      ),
    );
  }
}