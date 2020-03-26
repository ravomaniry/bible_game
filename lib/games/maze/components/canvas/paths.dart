import 'dart:ui' as ui;

import 'package:bible_game/app/theme/themes.dart';
import 'package:bible_game/games/maze/components/canvas/words_bg.dart';
import 'package:bible_game/games/maze/components/config.dart';
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
    final backgrounds = viewModel.backgrounds;

    if (board == null || backgrounds == null) {
      return SizedBox.shrink();
    } else {
      return RepaintBoundary(
        child: CustomPaint(
          size: Size(computeBoardPxWidth(board), computeBoardPxHeight(board)),
          painter: _Painter(
            paths: viewModel.paths,
            theme: viewModel.theme,
            backgrounds: backgrounds,
            confirmed: viewModel.confirmed,
            hints: viewModel.hints,
            start: board.start,
            end: board.end,
          ),
        ),
      );
    }
  }
}

class _Painter extends CustomPainter {
  final Coordinate start;
  final Coordinate end;
  final List<List<Coordinate>> paths;
  final AppColorTheme theme;
  final List<Coordinate> confirmed;
  final List<Coordinate> hints;
  final Map<String, ui.Image> backgrounds;

  _Painter({
    @required this.start,
    @required this.end,
    @required this.paths,
    @required this.confirmed,
    @required this.theme,
    @required this.backgrounds,
    @required this.hints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _paintPaths(canvas);
    _paintConfirmed(canvas);
    _paintStartEnd(canvas);
    _paintHints(canvas);
  }

  void _paintPaths(Canvas canvas) {
    final linePaint = _getLinePaint(theme);
    final checkpointPaint = _getCheckpointPaint(theme.primary);
    for (var pathIndex = 0; pathIndex < paths.length; pathIndex++) {
      final path = paths[pathIndex];
      for (var i = 0, max = path.length; i < max; i++) {
        _drawCheckpoint(path[i], canvas, checkpointPaint);
        if (i != max - 1) {
          _drawLine(path[i], path[i + 1], canvas, linePaint);
        }
      }
    }
  }

  void _paintConfirmed(Canvas canvas) {
    final confirmedImage = backgrounds["confirmed"];
    if (confirmedImage != null) {
      for (final point in confirmed) {
        if (!hints.contains(point)) {
          painImageInRect(point, confirmedImage, canvas);
        }
      }
    }
  }

  void _paintHints(Canvas canvas) {
    if (backgrounds != null) {
      final image = backgrounds["hint"];
      if (image != null) {
        for (final point in hints) {
          painImageInRect(point, image, canvas);
        }
      }
    }
  }

  void _paintStartEnd(Canvas canvas) {
    final startImage = backgrounds["start"];
    if (startImage != null) {
      painImageInRect(start, startImage, canvas);
      painImageInRect(end, startImage, canvas);
    }
  }

  void _drawCheckpoint(Coordinate coordinate, Canvas canvas, Paint paint) {
    canvas.drawRRect(_getCheckpointRect(coordinate), paint);
  }

  void _drawLine(Coordinate start, Coordinate end, Canvas canvas, Paint paint) {
    canvas.drawLine(_centerInPx(start), _centerInPx(end), paint);
  }

  @override
  bool shouldRepaint(_Painter old) {
    return old.paths != paths;
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
