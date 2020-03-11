import 'package:bible_game/app/theme/themes.dart';
import 'package:bible_game/games/maze/components/cell.dart';
import 'package:bible_game/games/maze/components/maze_board.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/games/maze/redux/paths_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';

final _linePaintCache = Map<AppColorTheme, Paint>();
final _checkpointPaintCache = Map<Color, Paint>();

Paint _getLinePaint(AppColorTheme theme) {
  var paint = _linePaintCache[theme];
  if (paint == null) {
    paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..color = theme.primary.withAlpha(180);
    _linePaintCache[theme] = paint;
  }
  return paint;
}

Paint _getCheckpointPaint(Color color) {
  var paint = _checkpointPaintCache[color];
  if (paint == null) {
    paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;
    _checkpointPaintCache[color] = paint;
  }
  return paint;
}

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
          painter: _Painter(paths, theme, board.start, board.end),
        ),
      );
    }
  }
}

class _Painter extends CustomPainter {
  final List<List<Coordinate>> _paths;
  final AppColorTheme _theme;
  final Coordinate _start;
  final Coordinate _end;

  _Painter(this._paths, this._theme, this._start, this._end);

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = _getLinePaint(_theme);
    final rectPaint = _getCheckpointPaint(_theme.primary);

    for (var pathIndex = 0; pathIndex < _paths.length; pathIndex++) {
      final path = _paths[pathIndex];
      for (var i = 0, max = path.length; i < max; i++) {
        _drawCheckpoint(path[i], canvas, rectPaint);
        if (i != max - 1) {
          _drawLine(path[i], path[i + 1], canvas, linePaint);
        }
      }
    }
    _drawCheckpoint(_start, canvas, _getCheckpointPaint(_theme.accentLeft));
    _drawCheckpoint(_end, canvas, _getCheckpointPaint(_theme.accentLeft));
  }

  void _drawCheckpoint(Coordinate coordinate, Canvas canvas, Paint paint) {
    canvas.drawRRect(_getCheckpointRect(coordinate), paint);
  }

  void _drawLine(Coordinate start, Coordinate end, Canvas canvas, Paint paint) {
    canvas.drawLine(_centerInPx(start), _centerInPx(end), paint);
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

final _padding = 2;
final _radius = Radius.circular(2);

RRect _getCheckpointRect(Coordinate point) {
  final topLeft = Offset(cellSize * point.x, cellSize * point.y);
  return RRect.fromLTRBR(
    topLeft.dx + 2 * _padding,
    topLeft.dy + 2 * _padding,
    topLeft.dx + cellSize - _padding,
    topLeft.dy + cellSize - _padding,
    _radius,
  );
}
