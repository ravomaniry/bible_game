import 'package:bible_game/app/theme/themes.dart';
import 'package:bible_game/games/maze/models/maze_cell.dart';
import 'package:bible_game/models/word.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

final double cellSize = 24;
final emptyCell = SizedBox(width: cellSize, height: cellSize);

class MazeCellWidget extends StatelessWidget {
  final List<Word> wordsToFind;
  final AppColorTheme theme;
  final MazeCell cell;

  MazeCellWidget({
    @required this.wordsToFind,
    @required this.theme,
    @required this.cell,
  });

  @override
  Widget build(BuildContext context) {
    if (wordIndex == -1 && cell.environment == CellEnv.none) {
      return emptyCell;
    } else {
      return SizedBox(
        width: cellSize,
        height: cellSize,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _background,
            image: DecorationImage(
              image: AssetImage(_image),
              fit: BoxFit.fill,
            ),
          ),
          child: Text(_text),
        ),
      );
    }
  }

  String get _text {
    if (wordIndex >= 0 && charIndex >= 0) {
      return wordsToFind[wordIndex].chars[charIndex].value.toUpperCase();
    }
    return "";
  }

  Color get _background {
    switch (cell.environment) {
      case CellEnv.frontier:
        return Color.fromARGB(40, 218, 255, 127);
      case CellEnv.forest:
        return Color.fromARGB(100, 218, 255, 127);
      default:
        return Colors.transparent;
    }
  }

  String get _image {
    switch (cell.environment) {
      case CellEnv.forest:
        return "assets/images/maze/forest.png";
      case CellEnv.upLeft:
        return "assets/images/maze/up_left.png";
      case CellEnv.upRight:
        return "assets/images/maze/up_right.png";
      case CellEnv.downRight:
        return "assets/images/maze/down_right.png";
      case CellEnv.downLeft:
        return "assets/images/maze/down_left.png";
      case CellEnv.frontier:
        return "assets/images/maze/frontier.png";
      default:
        return "assets/images/maze/word.png";
    }
  }

  int get wordIndex => cell.first.wordIndex;

  int get charIndex => cell.first.charIndex;
}
