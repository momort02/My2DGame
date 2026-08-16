Instructions pour assets (images et sons)

1) Images (sprites)
- Créez le dossier `assets/images/` à la racine du projet.
- Ajoutez par exemple `player.png` et `enemy.png` si vous voulez utiliser de vrais sprites.
- Format recommandé: PNG, taille adaptée mobile (48x48 -> 128x128 selon style pixelart).

2) Sons
- Créez le dossier `assets/audio/`.
- Ajoutez `hit.wav` et `jump.wav` (courts, <1s).
- Ces fichiers seront joués automatiquement lors des attaques et sauts si présents.

3) Mise à jour pubspec
- `pubspec.yaml` inclut déjà les dossiers `assets/images/` et `assets/audio/`.
- Exécutez `flutter pub get` après avoir ajouté des fichiers.

4) Test
- Lancer `flutter run` et vérifier que les sons se jouent et que les sprites remplacent les rectangles.
