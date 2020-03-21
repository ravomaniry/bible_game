import 'package:bible_game/canvas_utils/char_painter.dart';
import 'package:bible_game/games/words_in_word/actions/cells_action.dart';
import 'package:bible_game/games/words_in_word/components/result_canvas.dart';
import 'package:bible_game/games/words_in_word/view_model.dart';
import 'package:bible_game/models/cell.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WordsInWordResult extends StatefulWidget {
  final WordsInWordViewModel _viewModel;
  final CharStyles styles;
  final painterCache = CharPainterCache();

  WordsInWordResult(this._viewModel, this.styles);

  factory WordsInWordResult.fromViewModel(WordsInWordViewModel viewModel) {
    return WordsInWordResult(viewModel, CharStyles.fromTheme(viewModel.theme));
  }

  @override
  _WordsInWordResultState createState() => _WordsInWordResultState();
}

class _WordsInWordResultState extends State<WordsInWordResult> {
  void checkScreenWidth(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;
    if (widget._viewModel.config.screenWidth != currentWidth) {
      widget._viewModel.updateScreenWidth(currentWidth);
    }
  }

  @override
  Widget build(BuildContext context) {
    checkScreenWidth(context);
    final viewModel = widget._viewModel;
    final verse = viewModel.verse;
    final cells = viewModel.wordsInWord.cells;
    if (verse != null && cells != null) {
      return Expanded(
        child: Stack(
          children: [
            CustomPaint(
              size: Size(viewModel.config.screenWidth, _computeHeight(cells)),
              painter: ResultPainter(
                verse: verse,
                cells: cells,
                painters: widget.painterCache,
                styles: widget.styles,
              ),
            ),
          ],
        ),
      );
    }
    return Text("Nothing to show!!!");
  }
}

double _computeHeight(List<List<Cell>> cells) {
  return cells.length * (cellHeight + cellMargin) + cellMargin;
}
