import 'package:bible_game/app/theme/themes.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/maze_cell.dart';
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
        decoration: BoxDecoration(color: Colors.blue),
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
              cell: cell,
            ),
          )
          .toList(),
    );
  }
}

class _MazeCellWidget extends StatelessWidget {
  final List<Word> wordsToFind;
  final AppColorTheme theme;
  final MazeCell cell;

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
          border: _border,
          image: _image,
        ),
        child: Text(_text),
      ),
    );
  }

  String get _text {
    if (wordIndex >= 0 && charIndex >= 0) {
      return wordsToFind[wordIndex].chars[charIndex].value.toUpperCase();
    }
    return "";
  }

  Color get _background {
    if (cell.water == CellWater.none) {
      return Color.fromARGB(255, 0, 187, 0);
    } else if (cell.water == CellWater.beach) {
      return Color.fromARGB(255, 218, 255, 127);
    }
    return Colors.transparent;
  }

  Border get _border {
    if (wordIndex >= 0) {
      return Border.all(
        color: theme.primary.withAlpha(40),
        style: BorderStyle.solid,
      );
    }
    return null;
  }

  DecorationImage get _image {
    switch (cell.water) {
      case CellWater.upLeft:
        return DecorationImage(
          image: AssetImage("assets/images/bottom_right.png"),
          fit: BoxFit.fill,
        );
      case CellWater.upRight:
        return DecorationImage(
          image: AssetImage("assets/images/bottom_left.png"),
          fit: BoxFit.fill,
        );
      case CellWater.downRight:
        return DecorationImage(
          image: AssetImage("assets/images/top_left.png"),
          fit: BoxFit.fill,
        );
      case CellWater.downLeft:
        return DecorationImage(
          image: AssetImage("assets/images/top_right.png"),
          fit: BoxFit.fill,
        );
      case CellWater.beach:
        return DecorationImage(
          image: AssetImage("assets/images/beach.png"),
          fit: BoxFit.fill,
        );
      default:
        return null;
    }
  }

  int get wordIndex => cell.first.wordIndex;

  int get charIndex => cell.first.charIndex;
}
