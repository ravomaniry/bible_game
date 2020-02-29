import 'dart:math';

import 'package:bible_game/app/theme/themes.dart';
import 'package:bible_game/games/maze/components/cell.dart';
import 'package:bible_game/games/maze/components/maze_board.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/games/maze/redux/paths_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';

final _tmpPaint = Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = 2
  ..color = Colors.deepOrange;

class MazePaths extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector(
      builder: _builder,
      converter: pathConverter,
    );
  }

  Widget _builder(BuildContext context, PathsViewModel viewModel) {
    final board = viewModel.board;
    final paths = viewModel.paths;
    final theme = viewModel.theme;
    if (board == null) {
      return SizedBox.shrink();
    } else {
      return RepaintBoundary(
        child: CustomPaint(
          size: Size(computeBoardPxWidth(board), computeBoardPxHeight(board)),
          painter: _Painter(paths, theme),
        ),
      );
    }
  }
}

class _Painter extends CustomPainter {
  final List<List<Coordinate>> _paths;
  final AppColorTheme _theme;

  _Painter(this._paths, this._theme);

  @override
  void paint(Canvas canvas, Size size) {
    for (final path in _paths) {
      for (var i = 0, max = path.length; i < max; i++) {
        _drawCircle(path[i], canvas);
        if (i != max - 1) {
          _drawLine(path[i], path[i + 1], canvas);
        }
      }
    }
  }

  void _drawCircle(Coordinate coordinate, Canvas canvas) {
    canvas.drawCircle(_centerInPx(coordinate, 1), cellSize / 2 - 2, _tmpPaint);
  }

  void _drawLine(Coordinate start, Coordinate end, Canvas canvas) {
    canvas.drawLine(
      _centerInPx(start, _getLineMarginX(start, end)),
      _centerInPx(end, _getLineMarginY(start, end)),
      _tmpPaint,
    );
  }

  @override
  bool shouldRepaint(_Painter old) {
    return old._paths != _paths;
  }
}

Offset _centerInPx(Coordinate point, double margin) {
  return Offset(
    (point.x + 0.5) * cellSize + margin,
    (point.y + 0.5) * cellSize + margin,
  );
}

double _getLineMarginX(Coordinate start, Coordinate end) {
  final sign = start.x > end.x ? -1 : 1;
  if (start.x == end.x) {
    return 0;
  } else if (start.y == end.y) {
    return sign * cellSize / 2;
  } else {
    return sign * cellSize / 2 * sin(pi / 4);
  }
}

double _getLineMarginY(Coordinate start, Coordinate end) {
  final sign = start.y > end.y ? -1 : 1;
  if (start.y == end.y) {
    return 0;
  } else if (start.x == end.x) {
    return sign * cellSize / 2;
  } else {
    return sign * cellSize / 2 * sin(pi / 4);
  }
}
