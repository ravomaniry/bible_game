import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/games/words_in_word/actions/cells_action.dart';
import 'package:bible_game/games/words_in_word/components/result_animation_painter.dart';
import 'package:bible_game/games/words_in_word/components/result_painter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Revealed animation", () {
    final maxHeight = cellHeight - cellMargin;
    final maxWidth = cellWidth - cellMargin / 2;
    expect(
      getAnimatedRect(Coordinate(1, 1), 0),
      Rect.fromLTRB(cellWidth, cellHeight + marginTop, cellWidth, cellHeight + marginTop),
    );
    expect(
      getAnimatedRect(Coordinate(1, 1), 0.25),
      Rect.fromLTRB(
        cellWidth,
        cellHeight + marginTop,
        cellWidth + maxWidth / 2,
        cellHeight + maxHeight / 2 + marginTop,
      ),
    );
    expect(
      getAnimatedRect(Coordinate(1, 1), 0.5),
      Rect.fromLTRB(
        cellWidth,
        cellHeight + marginTop,
        cellWidth + maxWidth,
        cellHeight + maxHeight + marginTop,
      ),
    );
    expect(
      getAnimatedRect(Coordinate(1, 1), 0.75),
      Rect.fromLTRB(
        cellWidth + maxWidth / 2,
        cellHeight + maxHeight / 2 + marginTop,
        cellWidth + maxWidth,
        cellHeight + maxHeight + marginTop,
      ),
    );
    expect(
      getAnimatedRect(Coordinate(1, 1), 1),
      Rect.fromLTRB(
        cellWidth + maxWidth,
        cellHeight + maxHeight + marginTop,
        cellWidth + maxWidth,
        cellHeight + maxHeight + marginTop,
      ),
    );
  });
}
