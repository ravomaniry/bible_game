import 'package:bible_game/app/theme/themes.dart';
import 'package:bible_game/games/maze/models.dart';
import 'package:bible_game/models/cell.dart';
import 'package:bible_game/models/word.dart';
import 'package:bidirectional_scroll_view/bidirectional_scroll_view.dart';
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
      children: row.map(_buildCell).toList(),
    );
  }

  Widget _buildCell(MazeCell cell) {
    return SizedBox(
      width: cellSize,
      height: cellSize,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.primary.withAlpha(100),
            style: BorderStyle.solid,
          ),
        ),
        child: Text(getDisplayTextAt(cell.first)),
      ),
    );
  }

  String getDisplayTextAt(Cell cell) {
    if (cell.wordIndex >= 0 && cell.charIndex >= 0) {
      return wordsToFind[cell.wordIndex].chars[cell.charIndex].value.toUpperCase();
    }
    return "";
  }
}
