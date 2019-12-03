import 'package:bible_game/models/cell.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/redux/words_in_word/view_model.dart';
import 'package:bible_game/statics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WordsInWordResult extends StatelessWidget {
  final WordsInWordViewModel _viewModel;
  static final double cellWidth = 24;
  static final double cellHeight = 28;

  WordsInWordResult(this._viewModel);

  void checkScreenWidth(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;
    if (_viewModel.screenWidth != currentWidth) {
      _viewModel.updateScreenWidth(currentWidth);
    }
  }

  @override
  Widget build(BuildContext context) {
    checkScreenWidth(context);
    final verse = _viewModel.verse;
    final cells = _viewModel.cells;

    if (verse != null && cells != null) {
      final List<Widget> rowWidgets = _viewModel.cells.map(_buildRow).toList();
      return Expanded(
        child: Container(
          decoration: BoxDecoration(color: WordInWordsStyles.resultBackgroundColor),
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
    return _CellDisplay(word, cell);
  }
}

class _CellDisplay extends StatelessWidget {
  final Word _word;
  final Cell _cell;

  _CellDisplay(this._word, this._cell);

  Color getBackgroundColor(Char char) {
    if (_word.isSeparator) {
      if (char.value == " ") {
        return Colors.transparent;
      }
      return WordInWordsStyles.wordsSeparatorColor;
    } else if (_word.resolved) {
      return WordInWordsStyles.revealedWordColor;
    } else if (char.resolved) {
      return WordInWordsStyles.revealedCharColor;
    }
    return WordInWordsStyles.unrevealedWordColor;
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
      return WordInWordsStyles.separatorCharStyle;
    } else if (_word.resolved) {
      return WordInWordsStyles.revealedWordStyle;
    } else if (char.resolved) {
      return WordInWordsStyles.revealedCharStyle;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final char = _word.chars[_cell.charIndex];
    return SizedBox(
      width: WordsInWordResult.cellWidth,
      height: WordsInWordResult.cellHeight,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 220),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: getBackgroundColor(char),
        ),
        alignment: Alignment.center,
        key: Key("${_cell.wordIndex}_${_cell.charIndex}"),
        margin: EdgeInsets.only(right: 2, bottom: 6),
        child: Center(
          child: Text(
            getContentToDisplay(char),
            style: getTextStyle(char),
          ),
        ),
      ),
    );
  }
}
