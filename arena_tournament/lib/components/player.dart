import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'fighter.dart';

/// Personnage contrôlé par le joueur.
///
/// N'a plus de logique propre à lui : c'est `ControlsOverlay` qui pilote
/// `moveDir`, `jump()` et `startAttack()` hérités de [Fighter]. L'ancien
/// `attack(target)` avec cast `dynamic` a été supprimé : la résolution des
/// dégâts se fait maintenant proprement dans `ArenaGame`.
class Player extends Fighter {
  Player({required Vector2 position})
      : super(position: position, color: const Color(0xFF31E6D8));
}