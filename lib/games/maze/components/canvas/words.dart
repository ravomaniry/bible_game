import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/games/maze/components/cell.dart';
import 'package:bible_game/games/maze/components/maze_board.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/redux/board_view_model.dart';
import 'package:bible_game/models/word.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

final _textStyle = TextStyle(
  color: Color.fromARGB(255, 40, 40, 40),
  fontWeight: FontWeight.w500,
);

class MazeWords extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, BoardViewModel>(
      converter: BoardViewModel.converter,
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, BoardViewModel viewModel) {
    final board = viewModel.state.board;
    final wordsToFind = viewModel.state.wordsToFind;

    if (board != null) {
      return RepaintBoundary(
        child: CustomPaint(
          size: Size(computeBoardPxWidth(board), computeBoardPxHeight(board)),
          painter: _Painter(board, wordsToFind),
        ),
      );
    }
    return SizedBox.shrink();
  }
}

class _Painter extends CustomPainter {
  final Board _board;
  final List<Word> _wordsToFind;

  _Painter(this._board, this._wordsToFind);

  @override
  void paint(Canvas canvas, Size size) {
    for (var x = 0; x < _board.width; x++) {
      for (var y = 0; y < _board.height; y++) {
        _paintText(x, y, canvas);
      }
    }
  }

  void _paintText(int x, int y, Canvas canvas) {
    final text = _getText(x, y);
    if (text != null) {
      final span = TextSpan(text: text, style: _textStyle);
      final painter = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();

      painter.paint(
        canvas,
        Offset(
          x * cellSize + (cellSize - painter.width) / 2,
          y * cellSize + (cellSize - painter.height) / 2,
        ),
      );
    }
  }

  String _getText(int x, int y) {
    final cell = _board.getAt(x, y).first;
    if (cell.wordIndex >= 0) {
      return _wordsToFind[cell.wordIndex].chars[cell.charIndex].comparisonValue.toUpperCase();
    }
    return null;
  }

  @override
  bool shouldRepaint(_Painter old) {
    return _board?.id != old._board?.id;
  }
}
