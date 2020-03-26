import 'dart:ui' as ui;

import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/games/maze/components/config.dart';
import 'package:bible_game/games/maze/components/maze_board.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/maze_cell.dart';
import 'package:bible_game/games/maze/redux/board_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class MazeBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, BoardViewModel>(
      converter: BoardViewModel.converter,
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, BoardViewModel viewModel) {
    final board = viewModel.state.board;
    final backgrounds = viewModel.state.backgrounds;
    if (board != null && backgrounds != null) {
      return RepaintBoundary(
        child: CustomPaint(
          size: Size(computeBoardPxWidth(board), computeBoardPxHeight(board)),
          painter: _Painter(board, backgrounds),
        ),
      );
    }
    return SizedBox.shrink();
  }
}

class _Painter extends CustomPainter {
  final Board _board;
  final Map<String, ui.Image> _backgrounds;

  _Painter(this._board, this._backgrounds);

  @override
  void paint(Canvas canvas, Size size) {
    for (var x = 0; x < _board.width; x++) {
      for (var y = 0; y < _board.height; y++) {
        _paintBackground(x, y, canvas);
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

  ui.Image _getImage(int x, int y) {
    final cell = _board.getAt(x, y);

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

  @override
  bool shouldRepaint(_Painter old) {
    return _board?.id != old._board?.id;
  }
}
