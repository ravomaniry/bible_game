import 'dart:math';

import 'package:animator/animator.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/games/words_in_word/actions/cells_action.dart';
import 'package:bible_game/games/words_in_word/components/result_animation_painter.dart';
import 'package:bible_game/games/words_in_word/components/result_painter.dart';
import 'package:bible_game/games/words_in_word/view_model.dart';
import 'package:bible_game/models/cell.dart';
import 'package:bible_game/utils/canvas_utils/paint.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WordsInWordResult extends StatefulWidget {
  final WordsInWordViewModel _viewModel;
  final CharStyles styles;
  final painterCache = PaintersCache();

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
                _AnimationRouter(
                  theme: viewModel.theme,
                  painters: widget.painterCache,
                  revealed: viewModel.wordsInWord.newlyRevealed,
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

class _AnimationRouter extends StatelessWidget {
  final AppColorTheme theme;
  final List<Coordinate> revealed;
  final PaintersCache painters;

  _AnimationRouter({
    @required this.theme,
    @required this.revealed,
    @required this.painters,
  });

  @override
  Widget build(BuildContext context) {
    if (revealed.isEmpty) {
      return SizedBox.shrink();
    }
    return Animator(
      duration: const Duration(milliseconds: 400),
      builder: (animation) => CustomPaint(
        painter: ResultAnimationPainter(
          theme: theme,
          revealed: revealed,
          painters: painters,
          animationValue: animation.value,
        ),
      ),
    );
  }
}

Size _computeSize(List<List<Cell>> cells, double screenWidth) {
  return Size(
    max(100, screenWidth - 5),
    cells.length * cellHeight + 2 * marginTop,
  );
}
