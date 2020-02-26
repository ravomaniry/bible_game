import 'dart:math';

import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:bible_game/games/maze/components/cell.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

AppColorTheme _converter(Store<AppState> store) {
  return store.state.theme;
}

class MazeSelection extends StatelessWidget {
  final Offset start;
  final Offset end;
  final List<Coordinate> selected;

  MazeSelection({
    @required this.start,
    @required this.end,
    @required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return StoreConnector(
      converter: _converter,
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, AppColorTheme theme) {
    if (start != null && end != null) {
      return CustomPaint(
        painter: _Painter(start: start, end: end, selected: selected, theme: theme),
        size: Size(
          max(start.dx, end.dx) + 20,
          max(start.dy, end.dy) + 20,
        ),
      );
    }
    return SizedBox.shrink();
  }
}

class _Painter extends CustomPainter {
  final Offset start;
  final Offset end;
  final List<Coordinate> selected;
  final AppColorTheme theme;

  _Painter({
    @required this.start,
    @required this.end,
    @required this.selected,
    @required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (start != null && end != null) {
      if (selected != null) {
        final rects = getSelectedRects(selected);
        _paintRects(rects, canvas);
      } else {
        _paintLine(canvas);
      }
    }
  }

  void _paintRects(List<RRect> rects, Canvas canvas) {
    final paint = _getSelectPaint(theme);
    for (final rect in rects) {
      canvas.drawRRect(rect, paint);
    }
  }

  void _paintLine(Canvas canvas) {
    canvas.drawLine(start, end, _linePaint);
  }

  @override
  bool shouldRepaint(_Painter old) {
    return old.start != start || old.end != end || old.selected != selected;
  }
}

List<RRect> getSelectedRects(List<Coordinate> selected) {
  return selected
      .map((cell) => createRoundedRect(
            cell.x * cellSize,
            cell.y * cellSize,
            (cell.x + 1) * cellSize,
            (cell.y + 1) * cellSize,
          ))
      .toList();
}

RRect createRoundedRect(double x1, double y1, double x2, double y2) {
  final rect = Rect.fromPoints(Offset(x1, y1), Offset(x2, y2));
  return RRect.fromRectXY(rect, 4, 4);
}

final _linePaint = Paint()
  ..style = PaintingStyle.stroke
  ..color = Color.fromARGB(100, 255, 0, 0)
  ..strokeWidth = 2;

Paint _getSelectPaint(AppColorTheme theme) => Paint()
  ..style = PaintingStyle.stroke
  ..color = theme.primary
  ..strokeWidth = 4;
