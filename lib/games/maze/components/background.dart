import 'dart:ui' as ui;

import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/games/maze/components/cell.dart';
import 'package:bible_game/games/maze/components/maze_board.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/maze_cell.dart';
import 'package:bible_game/games/maze/redux/view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_redux/flutter_redux.dart';

class MazeBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, MazeViewModel>(
      converter: MazeViewModel.converter,
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, MazeViewModel viewModel) {
    final board = viewModel.state.board;
    final backgrounds = viewModel.state.backgrounds;

    if (board != null && backgrounds != null) {
      return CustomPaint(
        size: Size(computeBoardPxWidth(board), computeBoardPxHeight(board)),
        painter: _Painter(board, backgrounds),
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
        final image = _getImage(_board.getAt(x, y));
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
    }
  }

  ui.Image _getImage(MazeCell cell) {
    if (cell.first.wordIndex >= 0) {
      return _backgrounds["word"];
    } else {
      switch (cell.environment) {
        case CellEnv.forest:
          return _backgrounds["forest"];
        case CellEnv.frontier:
          return _backgrounds["frontier"];
        case CellEnv.upRight:
          return _backgrounds["upRight"];
        case CellEnv.downRight:
          return _backgrounds["downRight"];
        case CellEnv.downLeft:
          return _backgrounds["downLeft"];
        case CellEnv.upLeft:
          return _backgrounds["upLeft"];
        default:
          return null;
      }
    }
  }

  @override
  bool shouldRepaint(_Painter old) {
    return _board?.id != old._board?.id;
  }
}
