import 'dart:ui' as ui;

import 'package:bible_game/games/maze/components/cell.dart';
import 'package:bible_game/games/maze/components/maze_board.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/maze_cell.dart';
import 'package:bible_game/games/maze/redux/view_model.dart';
import 'package:bible_game/models/word.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final _textStyle = TextStyle(
  color: Color.fromARGB(255, 40, 40, 40),
  fontWeight: FontWeight.w500,
);

class MazeBackground extends StatelessWidget {
  final MazeViewModel _viewModel;

  MazeBackground(this._viewModel);

  @override
  Widget build(BuildContext context) {
    final board = _viewModel.state.board;
    final backgrounds = _viewModel.state.backgrounds;
    final wordsToFind = _viewModel.state.wordsToFind;

    if (board != null && backgrounds != null) {
      return RepaintBoundary(
        child: CustomPaint(
          size: Size(computeBoardPxWidth(board), computeBoardPxHeight(board)),
          painter: _Painter(board, wordsToFind, backgrounds),
        ),
      );
    }
    return SizedBox.shrink();
  }
}

class _Painter extends CustomPainter {
  final Board _board;
  final Map<String, ui.Image> _backgrounds;
  final List<Word> _wordsToFind;

  _Painter(this._board, this._wordsToFind, this._backgrounds);

  @override
  void paint(Canvas canvas, Size size) {
    for (var x = 0; x < _board.width; x++) {
      for (var y = 0; y < _board.height; y++) {
        _paintBackground(x, y, canvas);
        _paintText(x, y, canvas);
      }
    }
  }

  void _paintBackground(int x, int y, Canvas canvas) {
    final image = _getImage(x, y);
    final topLeft = Offset(x * cellSize, y * cellSize);
    final bottomRight = topLeft + Offset(cellSize, cellSize);

    if (image != null) {
      paintImage(
        canvas: canvas,
        rect: Rect.fromPoints(topLeft, bottomRight),
        image: image,
        fit: BoxFit.fill,
      );
    }
  }

  void _paintText(int x, int y, Canvas canvas) {
    final text = _getText(x, y);
    if (text != null) {
      final span = TextSpan(text: text, style: _textStyle);
      final painter = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();

      painter.paint(
        canvas,
        Offset(
          x * cellSize + (cellSize - painter.width) / 2,
          y * cellSize + (cellSize - painter.height) / 2,
        ),
      );
    }
  }

  ui.Image _getImage(int x, int y) {
    final cell = _board.getAt(x, y);
    if (cell.first.wordIndex >= 0) {
      return _backgrounds["word"];
    } else {
      switch (cell.environment) {
        case CellEnv.forest:
          return (x + y) % 3 == 0 ? null : _backgrounds["forest"];
        case CellEnv.frontier:
          return (x + y) % 3 == 0 ? null : _backgrounds["frontier"];
        case CellEnv.upRight:
          return (x + y) % 3 == 0 ? _backgrounds["upRight"] : _backgrounds["upRight2"];
        case CellEnv.downRight:
          return _backgrounds["downRight"];
        case CellEnv.downLeft:
          return (x + y) % 4 == 0 ? _backgrounds["downLeft"] : _backgrounds["downLeft2"];
        case CellEnv.upLeft:
          return _backgrounds["upLeft"];
        default:
          return null;
      }
    }
  }

  String _getText(int x, int y) {
    final cell = _board.getAt(x, y).first;
    if (cell.wordIndex >= 0) {
      return _wordsToFind[cell.wordIndex].chars[cell.charIndex].comparisonValue.toUpperCase();
    }
    return null;
  }

  @override
  bool shouldRepaint(_Painter old) {
    return _board?.id != old._board?.id;
  }
}
