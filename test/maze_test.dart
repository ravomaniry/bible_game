import 'package:bible_game/games/maze/actions/create_board.dart';
import 'package:bible_game/games/maze/models.dart';
import 'package:bible_game/main.dart';
import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/test_helpers/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String toString(x) {
    return x.toString();
  }

  test("Words in scope", () {
    final verse = BibleVerse.from(
      book: "",
      bookId: 1,
      chapter: 1,
      verse: 1,
      text: "Abcd efgh ijkl",
    );
    final inScope = getWordsInScopeForMaze(verse);
    expect(inScope.map((w) => w.value), ["Abcd", "efgh", "ijkl"]);
  });

  test("Board min size", () {
    final words1 = getWordsInScopeForMaze(BibleVerse.from(text: "ABC DEF GHIJ"));
    final words2 = getWordsInScopeForMaze(BibleVerse.from(text: "ABC DEF GHI JKL MNO PQR STU"));
    expect(getBoardSize(words1), 20);
    expect(getBoardSize(words2), 42);
  });

  test("Starting points and possible moves", () {
    final board = Board.create(6, 6);
    // empty board should start in the middle (3, 0)
    final points0 = getPossibleStartingPoints(0, board);
    expect(points0.map(toString).toList(), ["(0, 3)"]);
    final moves0 = getPossibleMoves(points0, 4, board);
    expect(moves0.map(toString).toList(), [
      "(0, 3, 0, -1)",
      "(0, 3, 1, -1)",
      "(0, 3, 1, 0)",
    ]);

    // 1st word starts at (0, 0) and ends at (0,2)
    board..set(0, 0, 0, 0)..set(0, 1, 0, 1)..set(0, 2, 0, 2);
    final points1 = getPossibleStartingPoints(1, board);
    expect(points1.map(toString).toList(), ["(1, 1)", "(1, 2)", "(1, 3)", "(0, 3)"]);
    // place 2 chars word
    final moves1_0 = getPossibleMoves(points1, 2, board);
    expect(moves1_0.map(toString).toList(), [
      // (1, 1)
      "(1, 1, 0, -1)",
      "(1, 1, 1, -1)",
      "(1, 1, 1, 0)",
      "(1, 1, 1, 1)",
      "(1, 1, 0, 1)",
      // (1, 2)
      "(1, 2, 0, -1)",
      "(1, 2, 1, -1)",
      "(1, 2, 1, 0)",
      "(1, 2, 1, 1)",
      "(1, 2, 0, 1)",
      "(1, 2, -1, 1)",
      // (1, 3)
      "(1, 3, 0, -1)",
      "(1, 3, 1, -1)",
      "(1, 3, 1, 0)",
      "(1, 3, 1, 1)",
      "(1, 3, 0, 1)",
      "(1, 3, -1, 1)",
      "(1, 3, -1, 0)",
      // (0, 3)
      "(0, 3, 1, -1)",
      "(0, 3, 1, 0)",
      "(0, 3, 1, 1)",
      "(0, 3, 0, 1)",
    ]);
    // 5 chars word (only some moves are possible)
    final moves1_2 = getPossibleMoves(points1, 5, board);
    expect(moves1_2.map(toString).toList(), [
      "(1, 1, 1, 0)",
      "(1, 1, 1, 1)",
      "(1, 1, 0, 1)",
      "(1, 2, 1, 0)",
      "(1, 3, 1, 0)",
      "(0, 3, 1, 0)",
    ]);

    // 2nd word starts at (3, 1) and ends at (1, 1) and 1st word is still there
    board..set(3, 1, 1, 0)..set(2, 1, 1, 1)..set(1, 1, 1, 2);
    final points2 = getPossibleStartingPoints(2, board);
    expect(points2.map(toString).toList(), ["(1, 0)", "(2, 0)", "(2, 2)", "(1, 2)"]);

    // 3rd Word ends at the bottom right edge
    board..set(5, 4, 2, 0)..set(5, 5, 2, 1);
    final points3 = getPossibleStartingPoints(3, board);
    expect(points3.map(toString).toList(), ["(4, 5)", "(4, 4)"]);
    final moves3 = getPossibleMoves(points3, 5, board);
    expect(moves3.map(toString).toList(), [
      "(4, 5, 0, -1)",
      "(4, 5, -1, 0)",
      "(4, 4, 0, -1)",
      "(4, 4, -1, 0)",
    ]);
  });

  test("Overlap", () {
    /// Start & end
    var words = [Word.from("ABC", 0, false), Word.from("DAB", 1, false)];
    var board = Board.create(6, 6)..set(0, 0, 0, 0)..set(0, 1, 0, 1)..set(0, 2, 0, 2);
    expect(getOverlaps(1, words, board), []);

    /// Overlap on end of active word
    final verse = BibleVerse.from(text: "dcba adeg FEHCI ceilm");
    words = getWordsInScopeForMaze(verse);
    board = Board.create(7, 7)..set(0, 2, 0, 0)..set(1, 2, 0, 1)..set(2, 2, 0, 2)..set(3, 2, 0, 3);
    final moves = getOverlaps(1, words, board).map(toString).toList();
    expect(moves, ["(3, 2, 1, 1)", "(3, 2, 0, 1)", "(3, 2, -1, 1)"]);

    /// Overlap in the middle + 1 invalid case
    board..set(3, 2, 1, 0)..set(3, 3, 1, 1)..set(3, 4, 1, 2)..set(3, 5, 1, 3);
    final moves1 = getOverlaps(2, words, board).map(toString).toList();
    expect(moves1, ["(2, 5, 1, -1)", "(2, 4, 1, 0)", "(4, 4, -1, 0)"]);

    /// Overlap on 2 position ++ Not allow overlap on overlapped char
    board..set(2, 4, 2, 0)..set(3, 4, 2, 1)..set(4, 4, 2, 2)..set(5, 4, 2, 3)..set(6, 4, 2, 4);
    final moves2 = getOverlaps(3, words, board).map(toString).toList();
    expect(moves2, ["(5, 4, 0, -1)", "(6, 6, 0, -1)", "(6, 2, 0, 1)"]);
  });

  test("Overlap with only 1 char words", () {
    final board = Board.create(10, 10)..set(0, 0, 0, 0);
    final List<Word> words = [
      Word.from("A", 0, false),
      Word.from("Abc", 1, false),
      Word.from("b", 2, false),
    ];
    expect(getOverlaps(1, words, board), []);
    board..set(0, 1, 1, 0)..set(0, 2, 1, 1)..set(0, 3, 1, 2);
    expect(getOverlaps(2, words, board), []);
  });

  test("persistMove", () {
    final board = Board.create(10, 10);
    final move = Move(Coordinate(0, 0), Coordinate(1, 1));
    persistMove(move, 4, 0, board);
    expect(board.getAt(0, 0).toString(), "0 0");
    expect(board.getAt(1, 1).toString(), "0 1");
    expect(board.getAt(2, 2).toString(), "0 2");
    expect(board.getAt(3, 3).toString(), "0 3");
    expect(board.getAt(4, 4).toString(), "-1 -1");
  });

  test("Trim board", () {
    final board = Board.create(10, 10)
      ..set(1, 1, 0, 0)
      ..set(2, 2, 0, 1)
      ..set(2, 3, 1, 0)
      ..set(2, 4, 1, 1);
    final trimmed = board.trim();
    expect(trimmed.width, 2);
    expect(trimmed.height, 4);
    expect(trimmed.getAt(0, 0).contains(0, 0), true);
    expect(trimmed.getAt(1, 1).contains(0, 1), true);
    expect(trimmed.getAt(1, 2).contains(1, 0), true);
    expect(trimmed.getAt(1, 3).contains(1, 1), true);
  });

  test("Create the board many times and expect 100% succees", () async {
    final stopAt = 300;
    final verse = BibleVerse.from(
      book: "Jaona",
      bookId: 4,
      chapter: 1,
      verse: 1,
      text: "Tamin'ny voalohany ny Teny, ary ny Teny tao amin'Andriamanitra,"
          " ary ny Teny dia Andriamanitra.",
    );
    for (var i = 0; i < stopAt; i++) {
      final board = await createMazeBoard(verse);
      expect(board, isNotNull);
    }
    print("֎ Tesed init maze $stopAt times and it is perfect (y)");
  });

  testWidgets("Maze game init", (WidgetTester tester) async {
    final store = newMockedStore();
    await tester.pumpWidget(BibleGame(store));
    await tester.pump(Duration(milliseconds: 10));
    await tester.tap(find.byKey(Key("game_1")));
    await tester.pump(Duration(milliseconds: 10));

    simulateMazeRandomGame(store);
  });
}
