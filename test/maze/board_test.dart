import 'package:bible_game/games/maze/actions/board_noises.dart';
import 'package:bible_game/games/maze/actions/board_utils.dart';
import 'package:bible_game/games/maze/actions/create_board.dart';
import 'package:bible_game/games/maze/actions/water.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/games/maze/models/maze_cell.dart';
import 'package:bible_game/games/maze/models/move.dart';
import 'package:bible_game/main.dart';
import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/test_helpers/async.dart';
import 'package:bible_game/test_helpers/store.dart';
import 'package:flutter/widgets.dart';
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

  test("Starting points and possible moves", () async {
    //   0 1 2 3 4 5
    // 0⁰A - - - - -
    // 1 B - - - - -
    // 2 C - - - - -
    // 3 D E F - - -
    // 4 - - - - - G
    // 5 - - - - +²H
    final words = getWordsInScopeForMaze(BibleVerse.from(text: "ABC DEF GH"));
    final board = Board.create(6, 6);
    // empty board should start in the middle (3, 0)
    final points0 = await getPossibleStartingPoints(0, board, words);
    expect(points0.map(toString).toList(), ["(0, 3)"]);
    final moves0 = getPossibleMoves(points0, 0, 4, board);
    expect(moves0.map(toString).toList(), [
      "(0, 3, 0, -1, 0, 4)",
      "(0, 3, 1, -1, 0, 4)",
      "(0, 3, 1, 0, 0, 4)",
    ]);

    // ABC word starts at (0, 0) and ends at (0,2)
    board..set(0, 0, 0, 0)..set(0, 1, 0, 1)..set(0, 2, 0, 2);
    final points1 = await getPossibleStartingPoints(1, board, words);
    expect(points1.map(toString).toList(), ["(1, 2)", "(0, 3)"]);
    // place 2 chars word
    final moves1_0 = getPossibleMoves(points1, 1, 2, board);
    expect(moves1_0.map(toString).toList(), [
      // (1, 2)
      "(1, 2, 0, -1, 1, 2)",
      "(1, 2, 1, -1, 1, 2)",
      "(1, 2, 1, 0, 1, 2)",
      "(1, 2, 1, 1, 1, 2)",
      "(1, 2, 0, 1, 1, 2)",
      "(1, 2, -1, 1, 1, 2)",
      // (0, 3)
      "(0, 3, 1, -1, 1, 2)",
      "(0, 3, 1, 0, 1, 2)",
      "(0, 3, 1, 1, 1, 2)",
      "(0, 3, 0, 1, 1, 2)",
    ]);
    // 5 chars word (only some moves are possible)
    final moves1_2 = getPossibleMoves(points1, 1, 5, board);
    expect(moves1_2.map(toString).toList(), [
      "(1, 2, 1, 0, 1, 5)",
      "(0, 3, 1, 0, 1, 5)",
    ]);

    // D.E.F 2nd word starts at (3, 1) and ends at (1, 1) and 1st word is still there
    board..set(0, 3, 1, 0)..set(1, 3, 1, 1)..set(2, 3, 1, 2);
    final points2 = await getPossibleStartingPoints(2, board, words);
    expect(points2.map(toString).toList(), ["(2, 2)", "(3, 3)", "(2, 4)"]);

    // 3rd Word ends at the bottom right corner
    board..set(5, 4, 2, 0)..set(5, 5, 2, 1);
    final points3 = await getPossibleStartingPoints(3, board, words);
    expect(points3.map(toString).toList(), ["(4, 5)"]);
    final moves3 = getPossibleMoves(points3, 3, 5, board);
    expect(moves3.map(toString).toList(), [
      "(4, 5, 0, -1, 3, 5)",
      "(4, 5, -1, 0, 3, 5)",
    ]);
  });

  test("Starting point - coordinates near a last point is forbidden", () async {
    //    0_1_2_3_4
    // 0  - - - - K
    // 1 ⁰D E - -¹F
    // 2 ³A B C + -
    // 3  - - + - G
    // 4  - - - -²A
    final words = getWordsInScopeForMaze(BibleVerse.from(text: "DE FK AG ABC GH"));
    final board = Board.create(5, 5);
    board..set(0, 1, 0, 0)..set(1, 1, 0, 1);
    board..set(4, 1, 1, 0)..set(4, 0, 1, 1);
    board..set(4, 4, 2, 0)..set(4, 3, 2, 1);
    board..set(0, 2, 3, 0)..set(1, 2, 3, 1)..set(2, 2, 3, 2);
    final points = await getPossibleStartingPoints(4, board, words);
    expect(points.map(toString).toList(), ["(3, 2)", "(2, 3)"]);
  });

  test("Overlap", () {
    /// A start of a word-¹ can not be overlapped
    //   0 1 2 3
    // 0 - A - -
    // 1 - B - -
    // 2 - C - -
    // 3 - - - -
    var words = [Word.from("ABC", 0, false), Word.from("DAB", 1, false)];
    var board = Board.create(6, 6)..set(1, 0, 0, 0)..set(1, 1, 0, 1)..set(1, 2, 0, 2);
    expect(getOverlaps(1, words, board), []);

    /// Overlap on end of active word
    //   0 1 2 3 4 5 6
    // 0 - - - - - - -
    // 1 - - - - - - -
    // 2⁰d c b a¹- - -
    // 3 - - - D - - -
    // 4 - - f E h c i
    // 5 - - - G - - -
    // 6 - - - - - - -
    final verse = BibleVerse.from(text: "dcba ADEG fehci CEILM");
    words = getWordsInScopeForMaze(verse);
    board = Board.create(7, 7);

    /// a.d.e.g
    board..set(0, 2, 0, 0)..set(1, 2, 0, 1)..set(2, 2, 0, 2)..set(3, 2, 0, 3);
    final moves = getOverlaps(1, words, board).map(toString).toList();
    expect(moves, [
      "(3, 2, 1, 1, 1, 4)",
      "(3, 2, 0, 1, 1, 4)",
      "(3, 2, -1, 1, 1, 4)",
    ]);

    /// F.e.h.c.i Overlap in the middle + 2 invalid case:
    /// - overlaps 2 words
    /// - starts next to last char
    board..set(3, 2, 1, 0)..set(3, 3, 1, 1)..set(3, 4, 1, 2)..set(3, 5, 1, 3);
    final moves1 = getOverlaps(2, words, board).map(toString).toList();
    expect(moves1, [
      "(2, 4, 1, 0, 2, 5)",
      "(4, 4, -1, 0, 2, 5)",
    ]);

    /// c.e.l.i.m Overlap on 2 position ++ Not allow overlap on overlapped char
    board..set(2, 4, 2, 0)..set(3, 4, 2, 1)..set(4, 4, 2, 2)..set(5, 4, 2, 3)..set(6, 4, 2, 4);
    final moves2 = getOverlaps(3, words, board).map(toString).toList();
    expect(moves2, [
      "(5, 4, 0, -1, 3, 5)",
      "(6, 6, 0, -1, 3, 5)",
      "(6, 2, 0, 1, 3, 5)",
    ]);
  });

  test("Overlap with only 1 char words", () {
    //   0 1 2 3 4 5 6 7 8 9
    // 0 A - - - - - - - - -
    // 1 a - - - - - - - - -
    // 2 b - - - - - - - - -
    // 3 c - - - - - - - - -
    // 4 - - - - - - - - - -
    final board = Board.create(10, 10)..set(0, 0, 0, 0);
    final List<Word> words = [
      Word.from("A", 0, false),
      Word.from("abc", 1, false),
      Word.from("b", 2, false),
    ];
    expect(getOverlaps(1, words, board), []);
    board..set(0, 1, 1, 0)..set(0, 2, 1, 1)..set(0, 3, 1, 2);
    expect(getOverlaps(2, words, board), []);
  });

  test("Overlap - should not start a word in a forbidden position", () {
    //   0 1 2 3 4 5 6 7
    // 0 - - Y - - - - -
    // 1 - - - T - - - -
    // 2 J E S O S Y - -
    // 3 - - - - - I - -
    // 4 - - - - - - R -
    // 5 - - - - - - - K
    // 6 - - - - - - - -
    // 7 - - - - - - - -
    final words = getWordsInScopeForMaze(BibleVerse.from(text: "Jesosy Kristy izay"));
    final board = Board.create(8, 8);
    // Jesosy (0, 2) => (5, 2)
    board..set(0, 2, 0, 0)..set(1, 2, 0, 1)..set(2, 2, 0, 2)..set(3, 2, 0, 3)..set(4, 2, 0, 4)..set(5, 2, 0, 5);
    // Kristy (7, 5) => (2, 0)
    board..set(7, 5, 1, 0)..set(6, 4, 1, 1)..set(5, 3, 1, 2)..set(4, 2, 1, 3)..set(3, 1, 1, 4)..set(2, 0, 1, 5);
    // Overlap would be on I if it was allowed
    final overlaps = getOverlaps(2, words, board);
    expect(overlaps, []);
  });

  test("Does not allow 2 words to form a diagonal cross", () async {
    //    0 1 2 3 4
    // 0 ⁰A -¹E F *
    // 1  - B x - *
    // 2  - x C - *
    // 3  x - - D *
    // 4  - - - - -
    final words = getWordsInScopeForMaze(BibleVerse.from(text: "ABCD EF Fghi"));
    final board = Board.create(5, 5);
    board..set(0, 0, 0, 0)..set(1, 1, 0, 1)..set(2, 2, 0, 2)..set(3, 3, 0, 3);
    board..set(2, 0, 1, 0)..set(3, 0, 1, 1);
    final overlaps = getOverlaps(2, words, board);
    expect(overlaps, []);
    final startingPoints = await getPossibleStartingPoints(2, board, words);
    final moves = getPossibleMoves(startingPoints, 0, 4, board).map(toString).toList();
    expect(moves, ["(4, 0, 0, 1, 0, 4)"]);
  });

  test("persistMove", () {
    //   0 1 2 3 4 5 6
    // 0 + - - - - - -
    // 1 - + - - - - -
    // 2 - - + - - - -
    // 3 - - - + - - -
    // 4 - - - - + - -
    // 5 - - - - - - -
    // 7 - - - - - - -
    final board = Board.create(7, 7);
    final move = Move(Coordinate(0, 0), Coordinate(1, 1), 0, 4);
    persistMove(move, board);
    expect(board.getAt(0, 0).toString(), "0 0");
    expect(board.getAt(1, 1).toString(), "0 1");
    expect(board.getAt(2, 2).toString(), "0 2");
    expect(board.getAt(3, 3).toString(), "0 3");
    expect(board.getAt(4, 4).toString(), "-1 -1");
  });

  test("Trim board", () {
    final board = Board.create(10, 10)..set(1, 1, 0, 0)..set(2, 2, 0, 1)..set(2, 3, 1, 0)..set(2, 4, 1, 1);
    final trimmed = board.trim();
    expect(trimmed.width, 2);
    expect(trimmed.height, 4);
    expect(trimmed.getAt(0, 0).contains(0, 0), true);
    expect(trimmed.getAt(1, 1).contains(0, 1), true);
    expect(trimmed.getAt(1, 2).contains(1, 0), true);
    expect(trimmed.getAt(1, 3).contains(1, 1), true);
  });

  testWidgets("Add noise - Overlaps - simple", (WidgetTester tester) async {
    //   0 1 2 3 4 5
    // 0 - - - A - -
    // 1 - - - E F D
    // 2 A B C D - H
    // 3 - - - - - H
    // 4 - - D E A H
    // 5 - - - - - -
    final board = Board.create(6, 6);
    var words = getWordsInScopeForMaze(BibleVerse.from(text: "ABC DEA EFD HHH AED"));
    board..set(0, 2, 0, 0)..set(1, 2, 0, 1)..set(2, 2, 0, 2);
    board..set(3, 2, 1, 0)..set(3, 1, 1, 1)..set(3, 0, 1, 2);
    board..set(3, 1, 2, 0)..set(4, 1, 2, 1)..set(5, 1, 2, 2);
    board..set(5, 2, 3, 0)..set(5, 3, 3, 1)..set(5, 4, 3, 2);
    board..set(4, 4, 4, 0)..set(3, 4, 4, 1)..set(2, 4, 4, 2);
    final overlapRefs = getNoiseOverlapRefs(words).map(toString).toList();
    expect(overlapRefs, [
      // 0
      "0 0,0 0",
      "0 1,0 1",
      "0 2,0 2",
      "0 0,1 2",
      // 1
      "1 0,1 0",
      "1 1,1 1",
      "1 2,1 2",
      "1 0,2 2",
      "1 1,2 0",
      // 2
      "2 0,2 0",
      "2 1,2 1",
      "2 2,2 2",
      // 3
      "3 0,3 0",
      "3 0,3 1",
      "3 0,3 2",
      "3 1,3 1",
      "3 1,3 2",
      "3 2,3 2",
    ]);
    final moves = await executeAndAdvanceTimer(() => getOverlapNoiseMoves(board, words), Duration(seconds: 1), tester);
    expect(moves.map(toString).toList(), [
      // 0 0, 0 0
      "(0, 2, 0, -1, 0, 3)",
      "(0, 2, 0, 1, 0, 3)",
      // 0 1, 0 1
      "(1, 3, 0, -1, 0, 3)",
      "(1, 1, 0, 1, 0, 3)",
      // 0 2, 0 2
      "(0, 4, 1, -1, 0, 3)",
      "(0, 0, 1, 1, 0, 3)",
      // 0 0,1 2
      "(0, 4, 0, -1, 1, 3)",
      "(0, 0, 0, 1, 1, 3)",
      "(3, 0, -1, 0, 0, 3)",
      // 1 0,1 0
      "(3, 2, -1, -1, 1, 3)", // 10
      // 1 2,1 2
      "(1, 0, 1, 0, 1, 3)",
      // 1 0,2 2
      "(1, 0, 1, 1, 2, 3)",
      // 1 1,2 0
      "(3, 1, -1, 0, 2, 3)",
    ]);
  });

  testWidgets("Noise overlaps - should not allow diagonal cross", (tester) async {
    //   0 1 2 3 4 5
    // 0 - - - - C I
    // 1 - - A - - E
    // 2 - B - - D -
    // 3 C - - R - -
    // 4 - I H - - -
    final board = Board.create(6, 5);
    final words = getWordsInScopeForMaze(BibleVerse.from(text: "ABC CI HRDE IC"));
    board..set(2, 1, 0, 0)..set(1, 2, 0, 1)..set(0, 3, 0, 2);
    board..set(0, 3, 1, 0)..set(1, 4, 1, 1);
    board..set(2, 4, 2, 0)..set(3, 3, 2, 1)..set(4, 2, 2, 2)..set(5, 1, 2, 3);
    board..set(5, 0, 3, 0)..set(4, 0, 3, 1);
    final moves = await executeAndAdvanceTimer(() => getOverlapNoiseMoves(board, words), Duration(seconds: 1), tester);
    expect(moves.map(toString).toList(), [
      "(2, 1, -1, 0, 0, 3)",
      "(0, 1, 0, 1, 0, 3)",
      "(2, 4, 1, 0, 2, 4)",
      "(5, 4, 0, -1, 2, 4)",
    ]);
  });

  test("Outer Waters (sea)", () {
    //   0 1 2 3 4 5
    // 0 - - - - - -
    // 1 - A D - - -
    // 2 E - - - - -
    // 3 - - - Z - -
    // 4 - - - - - -
    final board = Board.create(6, 6);
    board..set(1, 1, 0, 0)..set(2, 1, 0, 1)..set(0, 2, 1, 0)..set(3, 4, 2, 0);
    assignWaters(board);
    final waters = [
      [CellWater.upLeft, CellWater.none, CellWater.none, CellWater.upRight, CellWater.beach, CellWater.full],
      [CellWater.none, CellWater.none, CellWater.none, CellWater.none, CellWater.beach, CellWater.full],
      [CellWater.none, CellWater.none, CellWater.none, CellWater.downRight, CellWater.beach, CellWater.full],
      [CellWater.none, CellWater.downRight, CellWater.none, CellWater.none, CellWater.upRight, CellWater.beach],
      [CellWater.beach, CellWater.beach, CellWater.none, CellWater.none, CellWater.none, CellWater.beach],
      [CellWater.full, CellWater.beach, CellWater.downLeft, CellWater.none, CellWater.downRight, CellWater.beach],
    ];
    for (var x = 0; x < board.width; x++) {
      for (var y = 0; y < board.height; y++) {
        expect(board.getAt(x, y).water, waters[y][x]);
      }
    }
  });

  testWidgets("Create the board many times and expect 100% succees", (WidgetTester tester) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final stopAt = 100;
    final verse = BibleVerse.from(
      book: "Jaona",
      bookId: 4,
      chapter: 1,
      verse: 1,
      text: "Ny filazana ny razan'i Jesosy Kristy",
    );
    for (var i = 0; i < stopAt; i++) {
      final board = await executeAndAdvanceTimer(() => createMazeBoard(verse), Duration(minutes: 20), tester);
      expect(board, isNotNull);
      final words = getWordsInScopeForMaze(verse);
      for (var wIndex = 0; wIndex < words.length; wIndex++) {
        final word = words[wIndex];
        for (var cIndex = 0; cIndex < word.length; cIndex++) {
          expect(board.coordinateOf(wIndex, cIndex), isNotNull);
        }
      }
    }
    print("֎ Tesed init maze $stopAt times in ${DateTime.now().millisecondsSinceEpoch - now} ms");
  });

  testWidgets("Maze game init", (WidgetTester tester) async {
    final store = newMockedStore();
    await tester.pumpWidget(BibleGame(store));
    await tester.pump(Duration(milliseconds: 10));
    await tester.tap(find.byKey(Key("game_1")));
    await tester.pump(Duration(seconds: 10));
    simulateMazeRandomGame(store);
    await tester.pump(Duration(seconds: 10));
  });
}