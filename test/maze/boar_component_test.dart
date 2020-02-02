import 'package:bible_game/games/maze/components/tap_handler.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Get tapped cell", () {
    final board = Board.create(10, 10, 1);
    board..set(0, 0, 0, 0)..set(1, 1, 0, 1)..set(4, 5, 1, 0);
    expect(getTappedCell(Offset(10, 10), board), board.getAt(0, 0));
    expect(getTappedCell(Offset(25, 10), board), null);
    expect(getTappedCell(Offset(40, 40), board), board.getAt(1, 1));
    expect(getTappedCell(Offset(100, 130), board), board.getAt(4, 5));
    expect(getTappedCell(Offset(1000, 1000), board), null);
  });
}
