import 'package:bible_game/app/theme/themes.dart';
import 'package:bible_game/games/maze/models.dart';
import 'package:bible_game/models/cell.dart';
import 'package:bible_game/models/word.dart';
import 'package:bidirectional_scroll_view/bidirectional_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

final double cellSize = 20;

class MazeBoard extends StatelessWidget {
  final Board board;
  final AppColorTheme theme;
  final List<Word> wordsToFind;

  MazeBoard({
    @required this.board,
    @required this.theme,
    @required this.wordsToFind,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        child: BidirectionalScrollViewPlugin(
          child: SizedBox(
            width: board.width * cellSize,
            height: board.height * cellSize,
            child: Column(
              children: board.value.map(_buildRow).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(List<MazeCell> row) {
    return Row(
      children: row
          .map(
            (cell) => _MazeCellWidget(
              theme: theme,
              wordsToFind: wordsToFind,
              cell: cell.first,
            ),
          )
          .toList(),
    );
  }
}

class _MazeCellWidget extends StatelessWidget {
  final List<Word> wordsToFind;
  final AppColorTheme theme;
  final Cell cell;

  _MazeCellWidget({
    @required this.wordsToFind,
    @required this.theme,
    @required this.cell,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cellSize,
      height: cellSize,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _background,
          border: Border.all(
            color: theme.primary.withAlpha(100),
            style: BorderStyle.solid,
          ),
        ),
        child: Text(_text),
      ),
    );
  }

  String get _text {
    if (cell.wordIndex >= 0 && cell.charIndex >= 0) {
      return wordsToFind[cell.wordIndex].chars[cell.charIndex].value.toUpperCase();
    }
    return "";
  }

  Color get _background {
    if (cell.wordIndex >= 0) {
      switch (cell.wordIndex % 3) {
        case 0:
          return Colors.green;
        case 1:
          return Colors.deepOrangeAccent;
        default:
          return Colors.amber;
      }
    }
    return Colors.transparent;
  }
}
