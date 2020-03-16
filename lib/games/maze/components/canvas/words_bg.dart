import 'dart:ui' as ui;

import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:bible_game/games/maze/components/cell.dart';
import 'package:bible_game/games/maze/components/maze_board.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/games/maze/redux/board_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class MazeWordsBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, BoardViewModel>(
      converter: BoardViewModel.converter,
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, BoardViewModel viewModel) {
    final board = viewModel.state.board;
    final theme = viewModel.theme;
    final revealed = viewModel.state.revealed;
    if (board != null) {
      return RepaintBoundary(
        child: CustomPaint(
          size: Size(computeBoardPxWidth(board), computeBoardPxHeight(board)),
          painter: _Painter(
            board: board,
            revealed: revealed,
            theme: theme,
            hints: viewModel.state.hints,
            backgrounds: viewModel.state.backgrounds,
          ),
        ),
      );
    }
    return SizedBox.shrink();
  }
}

class _Painter extends CustomPainter {
  final Board board;
  final AppColorTheme theme;
  final List<List<bool>> revealed;
  final List<Coordinate> hints;
  final Map<String, ui.Image> backgrounds;
  Paint _revealedPaint;
  Paint _unrevealedPaint;
  Paint _startPaint;

  _Painter({
    @required this.board,
    @required this.revealed,
    @required this.theme,
    @required this.hints,
    @required this.backgrounds,
  }) {
    _revealedPaint = getFilledRectPaint(theme.neutral, 255);
    _unrevealedPaint = getFilledRectPaint(theme.neutral, 120);
    _startPaint = getFilledRectPaint(theme.primary, 255);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paintBackgrounds(canvas);
    _paintStartEnd(canvas);
  }

  void _paintBackgrounds(Canvas canvas) {
    for (var x = 0; x < board.width; x++) {
      for (var y = 0; y < board.height; y++) {
        final cell = board.getAt(x, y);
        if (cell.first.wordIndex >= 0) {
          final rRect = _getRect(x, y);
          final paint = revealed[y][x] ? _revealedPaint : _unrevealedPaint;
          canvas.drawRRect(rRect, paint);
        }
      }
    }
  }

  void _paintStartEnd(Canvas canvas) {
    canvas.drawRRect(_getRect(board.start.x, board.start.y), _startPaint);
    canvas.drawRRect(_getRect(board.end.x, board.end.y), _startPaint);
  }

  @override
  bool shouldRepaint(_Painter old) {
    return revealed != old.revealed;
  }
}

RRect _getRect(int x, int y) {
  final topLeft = Offset(x * cellSize, y * cellSize) + Offset(2, 2);
  final bottomRight = topLeft + Offset(cellSize, cellSize) - Offset(2, 2);
  return RRect.fromLTRBR(
    topLeft.dx,
    topLeft.dy,
    bottomRight.dx,
    bottomRight.dy,
    const Radius.circular(4),
  );
}

final _paintsCache = Map<String, Paint>();

Paint getFilledRectPaint(Color color, int alpha) {
  final key = "$color-$alpha";
  var paint = _paintsCache[key];
  if (paint == null) {
    paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withAlpha(alpha);
    _paintsCache[key] = paint;
  }
  return paint;
}

void painImageInRect(Coordinate point, ui.Image image, canvas) {
  final topLeft = Offset(point.x * cellSize, point.y * cellSize);
  final bottomRight = topLeft + Offset(cellSize, cellSize);
  paintImage(
    canvas: canvas,
    rect: Rect.fromPoints(topLeft, bottomRight),
    image: image,
    fit: BoxFit.fill,
  );
}
