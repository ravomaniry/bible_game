import 'dart:math';

import 'package:bible_game/games/words_in_word/actions/cells_action.dart';
import 'package:bible_game/games/words_in_word/components/result_canvas.dart';
import 'package:bible_game/games/words_in_word/view_model.dart';
import 'package:bible_game/models/cell.dart';
import 'package:bible_game/utils/canvas_utils/paint.dart';
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
      final size = _computeSize(cells, viewModel.config.screenWidth);
      return Expanded(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: Stack(
              children: [
                CustomPaint(
                  size: size,
                  painter: ResultPainter(
                    verse: verse,
                    cells: cells,
                    theme: viewModel.theme,
                    painters: widget.painterCache,
                    styles: widget.styles,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Text("Nothing to show!!!");
  }
}

Size _computeSize(List<List<Cell>> cells, double screenWidth) {
  return Size(
    max(100, screenWidth - 5),
    cells.length * cellHeight + 2 * marginTop,
  );
}
