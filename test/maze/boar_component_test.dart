import 'package:bible_game/games/maze/components/tap_handler.dart';
import 'package:bible_game/games/maze/create/board_utils.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/games/maze/models/move.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Get tapped cell", () {
    final board = Board.create(10, 10, 1);
    persistMove(Move(Coordinate(0, 0), Coordinate.downRight, 0, 2), board);
    persistMove(Move(Coordinate(4, 5), Coordinate.downRight, 1, 1), board);
    expect(getTappedCell(Offset(10, 10), board), board.getAt(0, 0));
    expect(getTappedCell(Offset(25, 10), board), null);
    expect(getTappedCell(Offset(40, 40), board), board.getAt(1, 1));
    expect(getTappedCell(Offset(100, 130), board), board.getAt(4, 5));
    expect(getTappedCell(Offset(1000, 1000), board), null);
  });
}
