import 'package:bible_game/app/theme/themes.dart';
import 'package:bible_game/games/maze/components/cell.dart';
import 'package:bible_game/games/maze/components/maze_board.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/games/maze/redux/paths_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';

final _tmpLinePaint = Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = 6
  ..color = Colors.deepOrange.withAlpha(150);

final _tmpCirclePaint = Paint()
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
    canvas.drawCircle(_centerInPx(coordinate, Offset(1, 1)), cellSize / 2 - 2, _tmpCirclePaint);
  }

  void _drawLine(Coordinate start, Coordinate end, Canvas canvas) {
    canvas.drawLine(
      _centerInPx(start, _getLineMargin(start, end)),
      _centerInPx(end, _getLineMargin(end, start)),
      _tmpLinePaint,
    );
  }

  @override
  bool shouldRepaint(_Painter old) {
    return old._paths != _paths;
  }
}

Offset _centerInPx(Coordinate point, Offset margin) {
  return Offset(
    (point.x + 0.5) * cellSize + margin.dx,
    (point.y + 0.5) * cellSize + margin.dy,
  );
}

Offset _getLineMargin(Coordinate start, Coordinate end) {
  final xSign = start.x > end.x ? -1 : 1;
  final ySign = start.y > end.y ? -1 : 1;
  final dx = start.x == end.x ? 0 : xSign * cellSize / 4;
  final dy = start.y == end.y ? 0 : ySign * cellSize / 4;
  return Offset(dx.toDouble(), dy.toDouble());
}
