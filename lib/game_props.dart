import 'package:flutter/foundation.dart';

class ImageAsset {
  final String imagePath;
  final int width;
  final int height;
  final int cols;
  final int rows;

  ImageAsset(
    this.imagePath,
    this.width,
    this.height, {
    this.cols = 1,
    this.rows = 1,
  });
}

class Assets {
  final player = ImageAsset('assets/images/sprites/player.png', 536, 534);
  final thrust = ImageAsset(
    'assets/images/sprites/thrust.png',
    7700,
    442,
    rows: 1,
    cols: 50,
  );
  final floorTiles = ImageAsset(
    'assets/images/bg/floor-tiles.png',
    1024,
    1024,
    rows: 8,
    cols: 8,
  );
  final wallMetal = ImageAsset(
    'assets/images/static/wall-metal.png',
    66,
    66,
    rows: 1,
    cols: 1,
  );
}

class GameProps {
  static const tileSize = 40.0;

  static const keyboardPlayerRotationFactor = 0.004;
  static const keyboardPlayerThrustForce = 0.01; // Newton

  static const playerMass = 4000.0; // kg
  static const playerThrustAcceleration =
      keyboardPlayerThrustForce / playerMass; // m/s2

  static const playerThrustAnimationDurationMs = 200.0;

  static bool renderBackground = !kIsWeb;

  static Assets get assets => Assets();
}
