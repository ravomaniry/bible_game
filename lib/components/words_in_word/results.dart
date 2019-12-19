import 'package:bible_game/models/cell.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/redux/themes/themes.dart';
import 'package:bible_game/redux/words_in_word/view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WordsInWordResult extends StatelessWidget {
  final WordsInWordViewModel _viewModel;
  static final double cellWidth = 24;
  static final double cellHeight = 28;

  WordsInWordResult(this._viewModel);

  void checkScreenWidth(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;
    if (_viewModel.config.screenWidth != currentWidth) {
      _viewModel.updateScreenWidth(currentWidth);
    }
  }

  @override
  Widget build(BuildContext context) {
    checkScreenWidth(context);
    final verse = _viewModel.verse;
    final cells = _viewModel.wordsInWord.cells;

    if (verse != null && cells != null) {
      final List<Widget> rowWidgets = cells.map(_buildRow).toList();
      return Expanded(
        child: Container(
          child: ListView(children: rowWidgets),
        ),
      );
    }
    return Text("Nothing to show!!!");
  }

  Widget _buildRow(List<Cell> _row) {
    return Wrap(children: _row.map(_buildCell).toList());
  }

  Widget _buildCell(Cell cell) {
    final word = _viewModel.verse.words[cell.wordIndex];
    return _CellDisplay(word, cell, _viewModel.theme);
  }
}

class _CellDisplay extends StatelessWidget {
  final Word _word;
  final Cell _cell;
  final AppColorTheme _theme;

  _CellDisplay(this._word, this._cell, this._theme);

  Color getBackgroundColor(Char char) {
    if (_word.isSeparator) {
      if (char.value == " ") {
        return Colors.transparent;
      }
      return _theme.primaryDark.withAlpha(100);
    } else if (_word.resolved) {
      return _theme.accentRight;
    } else if (_word.bonus != null) {
      return _theme.accentLeft.withAlpha(150);
    }
    return _theme.neutral.withAlpha(200);
  }

  String getContentToDisplay(Char char) {
    if (_word.isSeparator) {
      return char.value;
    } else if (_word.resolved) {
      return char.value;
    }
    return char.resolved ? char.value : "";
  }

  TextStyle getTextStyle(Char char) {
    if (_word.isSeparator) {
      return const TextStyle(color: Colors.white, fontWeight: FontWeight.bold);
    } else if (_word.resolved) {
      return TextStyle(color: _theme.neutral, fontWeight: FontWeight.bold);
    } else if (char.resolved && _word.bonus == null) {
      return TextStyle(color: _theme.accentLeft);
    } else if (char.resolved) {
      return TextStyle(color: _theme.neutral);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final char = _word.chars[_cell.charIndex];
    return _CellContainer(
      background: getBackgroundColor(char),
      key: Key("${_cell.wordIndex}_${_cell.charIndex}"),
      child: Center(
        child: Text(
          getContentToDisplay(char),
          style: getTextStyle(char),
        ),
      ),
    );
  }
}

class _CellContainer extends StatelessWidget {
  final Color background;
  final Widget child;
  final Key key;

  _CellContainer({
    @required this.background,
    @required this.child,
    @required this.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: key,
      width: WordsInWordResult.cellWidth,
      height: WordsInWordResult.cellHeight,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 220),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: background,
        ),
        alignment: Alignment.center,
        margin: EdgeInsets.only(right: 2, bottom: 6),
        child: child,
      ),
    );
  }
}
