import 'package:bible_game/games/maze/models/board.dart';
import 'package:flutter/cupertino.dart';

class MazeBackground extends CustomPainter {
  final Board _board;

  MazeBackground(this._board);

  @override
  void paint(Canvas canvas, Size size) {
    
  }

  @override
  bool shouldRepaint(MazeBackground old) {
    return _board != old._board;
  }
}
