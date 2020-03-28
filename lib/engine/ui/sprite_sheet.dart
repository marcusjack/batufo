import 'package:batufo/dart_types/dart_types.dart';
import 'package:batufo/engine/ui/sprite.dart';
import 'package:batufo/game_props.dart';

class SpriteSheet {
  List<Sprite> _sprites;
  final int spriteWidth;
  final int spriteHeight;
  final int cols;
  final int rows;
  SpriteSheet(
    String imagePath, {
    @required this.spriteWidth,
    @required this.spriteHeight,
    @required this.rows,
    @required this.cols,
  }) {
    _sprites = List(rows * cols);
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final x = (col * spriteWidth).toDouble();
        final y = (row * spriteHeight).toDouble();
        final w = spriteWidth.toDouble();
        final h = spriteHeight.toDouble();
        final sprite = Sprite(imagePath, x: x, y: y, width: w, height: h);
        _sprites[row * cols + col] = sprite;
      }
    }
  }

  int get spritesCount => _sprites.length;

  static SpriteSheet fromImageAsset(ImageAsset asset) {
    final spriteWidth = asset.width ~/ asset.cols;
    final spriteHeight = asset.height ~/ asset.rows;
    return SpriteSheet(
      asset.imagePath,
      spriteWidth: spriteWidth,
      spriteHeight: spriteHeight,
      rows: asset.rows,
      cols: asset.cols,
    );
  }

  Sprite getIndex(int idx) {
    assert(idx < _sprites.length, '$idx is larger than ${_sprites.length}');
    return _sprites[idx];
  }

  getRowCol(int row, int col) {
    final idx = row * cols + col;
    return getIndex(idx);
  }
}
