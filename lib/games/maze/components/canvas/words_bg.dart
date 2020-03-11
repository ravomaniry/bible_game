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
          painter: _Painter(board, revealed, theme, viewModel.state.confirmed),
        ),
      );
    }
    return SizedBox.shrink();
  }
}

class _Painter extends CustomPainter {
  final Board _board;
  final AppColorTheme _theme;
  final List<List<bool>> _revealed;
  final List<Coordinate> _confirmed;
  Paint _revealedPaint;
  Paint _unrevealedPaint;
  Paint _confirmedPaint;

  _Painter(this._board, this._revealed, this._theme, this._confirmed) {
    _revealedPaint = _getPaint(_theme.neutral, 255);
    _unrevealedPaint = _getPaint(_theme.neutral, 120);
    _confirmedPaint = _getPaint(_theme.primary, 255);
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var x = 0; x < _board.width; x++) {
      for (var y = 0; y < _board.height; y++) {
        final cell = _board.getAt(x, y);
        if (cell.first.wordIndex >= 0) {
          _paintBackground(x, y, canvas);
        }
      }
    }
    for (final point in _confirmed) {
      _paintConfirmed(point, canvas);
    }
    _paintBackground(_board.start.x, _board.start.y, canvas);
    _paintConfirmed(_board.start, canvas);
    _paintConfirmed(_board.end, canvas);
  }

  void _paintBackground(int x, int y, Canvas canvas) {
    final rRect = _getRect(x, y);
    final paint = _revealed[y][x] ? _revealedPaint : _unrevealedPaint;
    canvas.drawRRect(rRect, paint);
  }

  void _paintConfirmed(Coordinate point, Canvas canvas) {
    final rect = _getRect(point.x, point.y);
    canvas.drawRRect(rect, _confirmedPaint);
  }

  @override
  bool shouldRepaint(_Painter old) {
    return _revealed != old._revealed;
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

Paint _getPaint(Color color, int alpha) {
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
