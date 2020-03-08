import 'package:bible_game/app/theme/themes.dart';
import 'package:bible_game/games/maze/components/cell.dart';
import 'package:bible_game/games/maze/components/maze_board.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/games/maze/redux/paths_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
          painter: _Painter(paths, theme, board.end),
        ),
      );
    }
  }
}

class _Painter extends CustomPainter {
  final List<List<Coordinate>> _paths;
  final AppColorTheme _theme;
  final Coordinate _end;

  _Painter(this._paths, this._theme, this._end);

  @override
  void paint(Canvas canvas, Size size) {
    for (var pathIndex = 0; pathIndex < _paths.length; pathIndex++) {
      final path = _paths[pathIndex];
      for (var i = 0, max = path.length; i < max; i++) {
        _drawCheckpoint(path[i], canvas);
        if (i != max - 1) {
          _drawLine(path[i], path[i + 1], canvas);
        }
      }
    }
    _drawCheckpoint(_end, canvas);
  }

  void _drawCheckpoint(Coordinate coordinate, Canvas canvas) {
    canvas.drawRRect(_getCheckpointRect(coordinate), _tmpCirclePaint);
  }

  void _drawLine(Coordinate start, Coordinate end, Canvas canvas) {
    canvas.drawLine(_centerInPx(start), _centerInPx(end), _tmpLinePaint);
  }

  @override
  bool shouldRepaint(_Painter old) {
    return old._paths != _paths;
  }
}

Offset _centerInPx(Coordinate point) {
  return Offset(
    (point.x + 0.5) * cellSize,
    (point.y + 0.5) * cellSize,
  );
}

final _padding = 4;
final _radius = Radius.circular(4);

RRect _getCheckpointRect(Coordinate point) {
  final topLeft = Offset(cellSize * point.x, cellSize * point.y);
  return RRect.fromLTRBR(
    topLeft.dx + _padding,
    topLeft.dy + _padding,
    topLeft.dx + cellSize - _padding,
    topLeft.dy + cellSize - _padding,
    _radius,
  );
}
