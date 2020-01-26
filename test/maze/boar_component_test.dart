import 'package:bible_game/app/theme/themes.dart';
import 'package:bible_game/games/maze/components/cell.dart';
import 'package:bible_game/games/maze/components/maze_board.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/redux/state.dart';
import 'package:bible_game/games/maze/redux/view_model.dart';
import 'package:bible_game/utils/pair.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("build rows", () {
    final viewModel = MazeViewModel(
      theme: AppColorTheme(),
      state: MazeState.emptyState().copyWith(
        board: Board.create(10, 10),
      ),
    );
    // render at 0,0 => not render rows and cols beyond (5, 5)
    var screenLimit = Pair(Size(0, 0), Size(5, 5));
    var rows = buildRows(screenLimit, viewModel);
    expect(rows.length, 5);
    rows.forEach((row) {
      expect(row.children.length, 5);
      row.children.forEach((cell) => expect(cell is MazeCellWidget, true));
    });
    // In the middle
    screenLimit = Pair(Size(2, 4), Size(10, 9));
    rows = buildRows(screenLimit, viewModel);
    expect(rows.length, 9);
    expect(rows[0].children, [emptyCell]);
    expect(rows[1].children, [emptyCell]);
    expect(rows[2].children, [emptyCell]);
    expect(rows[3].children, [emptyCell]);
    for (var y = 4; y < 9; y++) {
      expect(rows[y].children[0], emptyCell);
      expect(rows[y].children[1], emptyCell);
      for (var x = 2; x < 10; x++) {
        expect(rows[y].children[x] is MazeCellWidget, true);
      }
    }
  });
}