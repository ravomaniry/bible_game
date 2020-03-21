import 'package:bible_game/canvas_utils/char_painter.dart';
import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/cell.dart';
import 'package:flutter/material.dart';

class ResultPainter extends CustomPainter {
  final double margin = 10;
  final CharStyles styles;
  final BibleVerse verse;
  final CharPainterCache painters;
  final List<List<Cell>> cells;

  ResultPainter({
    @required this.styles,
    @required this.verse,
    @required this.cells,
    @required this.painters,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(Offset(0, 0), Offset(0, 10), Paint());
  }

  @override
  bool shouldRepaint(ResultPainter old) {
    return old.verse != verse;
  }
}
