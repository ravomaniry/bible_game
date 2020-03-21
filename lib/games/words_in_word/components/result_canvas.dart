import 'package:bible_game/app/theme/themes.dart';
import 'package:bible_game/games/maze/components/cell.dart';
import 'package:bible_game/games/words_in_word/actions/cells_action.dart';
import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/cell.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/utils/canvas_utils/paint.dart';
import 'package:flutter/material.dart';

final marginTop = 5;

class ResultPainter extends CustomPainter {
  final double margin = 10;
  final CharStyles styles;
  final BibleVerse verse;
  final CharPainterCache painters;
  final List<List<Cell>> cells;
  final AppColorTheme theme;

  ResultPainter({
    @required this.styles,
    @required this.verse,
    @required this.cells,
    @required this.painters,
    @required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var y = cells.length - 1; y >= 0; y--) {
      final row = cells[y];
      for (var x = row.length - 1; x >= 0; x--) {
        _drawBackground(x, y, row[x], canvas);
        _drawText(x, y, row[x], canvas);
      }
    }
  }

  void _drawBackground(int x, int y, Cell cell, Canvas canvas) {
    final word = verse.words[cell.wordIndex];
    final paint = _getBackgroundPaint(word, cell.charIndex);
    final rect = _getRRect(x, y);
    canvas.drawRRect(rect, paint);
  }

  void _drawText(int x, int y, Cell cell, Canvas canvas) {
    final word = verse.words[cell.wordIndex];
    final value = _getTextToDisplay(word, cell.charIndex);
    if (value != "") {
      final painter = _getTextPainter(word, value);
      painter.paint(canvas, _getTextOffset(x, y, painter.width, painter.height));
    }
  }

  String _getTextToDisplay(Word word, int charIndex) {
    final char = word.chars[charIndex];
    if (word.isSeparator || word.resolved || char.resolved) {
      return char.value;
    } else if (word.bonus != null && charIndex == word.firstUnrevealedIndex) {
      return String.fromCharCode(0x2B50);
    }
    return "";
  }

  TextPainter _getTextPainter(Word word, String value) {
    var style = word.resolved ? styles.worResolved : styles.charResolved;
    if (word.isSeparator) {
      style = styles.separator;
    }
    return painters.getTextPaint(value, style);
  }

  Paint _getBackgroundPaint(Word word, int charIndex) {
    if (word.chars[charIndex].value == " ") {
      return painters.getFilledRectPaint(theme.neutral, alpha: 0);
    }
    if (word.isSeparator) {
      return painters.getFilledRectPaint(theme.primary, alpha: 60);
    } else if (word.resolved) {
      return painters.getFilledRectPaint(theme.accentRight);
    }
    return painters.getFilledRectPaint(theme.neutral);
  }

  @override
  bool shouldRepaint(ResultPainter old) {
    return old.verse != verse;
  }
}

Offset _getTextOffset(int x, int y, double textWidth, double textHeight) {
  return Offset(
    cellWidth * x + (cellSize - textWidth) / 2 - cellMargin / 4,
    marginTop + cellHeight * y + (cellHeight - textHeight) / 3,
  );
}

RRect _getRRect(int x, int y) {
  final left = cellWidth * x;
  final top = cellHeight * y + marginTop;
  return RRect.fromLTRBR(
    left,
    top,
    left + cellWidth - cellMargin / 2,
    top + cellHeight - cellMargin,
    Radius.circular(4),
  );
}
