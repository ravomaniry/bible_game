import 'package:bible_game/games/maze/create/board_noises.dart';
import 'package:bible_game/games/maze/create/board_utils.dart';
import 'package:bible_game/games/maze/create/create_board.dart';
import 'package:bible_game/games/maze/create/environment.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/games/maze/models/maze_cell.dart';
import 'package:bible_game/games/maze/models/move.dart';
import 'package:bible_game/main.dart';
import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/test_helpers/store.dart';
import 'package:bible_game/test_helpers/wait.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String toString(x) {
    return x.toString();
  }

  test("Set and cache coordinates", () {
    final board = Board.create(10, 10, 1);
    expect(board.coordinateOf(0, 0), isNull);
    board.startMove(Coordinate(2, 3));
    board.set(2, 3, 0, 1);
    expect(board.coordinateOf(0, 1), Coordinate(2, 3));
    board.set(0, 0, 0, 2);
    expect(board.coordinateOf(0, 2), Coordinate(0, 0));
    // duplicate => ignored + another word
    board.set(1, 1, 0, 2);
    board.set(0, 2, 2, 0);
    expect(board.coordinateOf(2, 0), Coordinate(0, 2));
    expect(board.coordinateOf(0, 1), Coordinate(2, 3));
    expect(board.coordinateOf(0, 2), Coordinate(0, 0));
  });

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

  test("persistMove", () {
    //   0 1 2 3 4 5 6
    // 0 + - - - - - -
    // 1 - + - - - x -
    // 2 - - + - x - -
    // 3 - - - * - - -
    // 4 - - - * - - -
    // 5 - - - - - - -
    // 7 - - - - - - -
    final board = Board.create(7, 7, 1);
    persistMove(Move(Coordinate(0, 0), Coordinate(1, 1), 0, 4), board);
    persistMove(Move(Coordinate(3, 3), Coordinate(1, -1), 1, 3), board);
    persistMove(Move(Coordinate(3, 3), Coordinate(0, 1), 2, 2), board);
    expect(board.getAt(0, 0).toString(), "0 0");
    expect(board.getAt(1, 1).toString(), "0 1");
    expect(board.getAt(2, 2).toString(), "0 2");
    expect(board.getAt(3, 3).toString(), "0 3,1 0,2 0");
    expect(board.getAt(4, 4).toString(), "-1 -1");
    expect(board.getAt(4, 2).toString(), "1 1");
    expect(board.getAt(5, 1).toString(), "1 2");
    expect(board.coordinateOf(0, 0), Coordinate(0, 0));
    expect(board.coordinateOf(0, 1), Coordinate(1, 1));
    expect(board.coordinateOf(0, 2), Coordinate(2, 2));
    expect(board.coordinateOf(1, 2), Coordinate(5, 1));
    expect(board.moves[0][0], [
      [Coordinate(0, 0), Coordinate(1, 1), Coordinate(2, 2), Coordinate(3, 3)]
    ]);
    expect(board.moves[3][3], [
      [Coordinate(3, 3), Coordinate(4, 2), Coordinate(5, 1)],
      [Coordinate(3, 3), Coordinate(3, 4)],
    ]);
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
    final board = Board.create(6, 6, 1);

    /// ABC
    // empty board should start in the middle (3, 0)
    final points0 = getPossibleStartingPoints(0, board, words);
    expect(points0, [Coordinate(0, 3)]);
    final moves0 = getPossibleMoves(points0, 0, 4, board);
    expect(moves0, [
      Move(Coordinate(0, 3), Coordinate.up, 0, 4),
      Move(Coordinate(0, 3), Coordinate.upRight, 0, 4),
      Move(Coordinate(0, 3), Coordinate.right, 0, 4),
    ]);
    persistMove(Move(Coordinate(0, 0), Coordinate.down, 0, 3), board);

    /// DEF
    final points1 = getPossibleStartingPoints(1, board, words);
    expect(points1, [Coordinate(1, 2), Coordinate(0, 3)]);
    // place 2 chars word
    final moves1_0 = getPossibleMoves(points1, 1, 2, board);
    expect(moves1_0, [
      // (1, 2)
      Move(Coordinate(1, 2), Coordinate.up, 1, 2),
      Move(Coordinate(1, 2), Coordinate.upRight, 1, 2),
      Move(Coordinate(1, 2), Coordinate.right, 1, 2),
      Move(Coordinate(1, 2), Coordinate.downRight, 1, 2),
      Move(Coordinate(1, 2), Coordinate.down, 1, 2),
      Move(Coordinate(1, 2), Coordinate.downLeft, 1, 2),
      // (0, 3)
      Move(Coordinate(0, 3), Coordinate.upRight, 1, 2),
      Move(Coordinate(0, 3), Coordinate.right, 1, 2),
      Move(Coordinate(0, 3), Coordinate.downRight, 1, 2),
      Move(Coordinate(0, 3), Coordinate.down, 1, 2),
    ]);
    // 5 chars word (only some moves are possible)
    final moves1_2 = getPossibleMoves(points1, 1, 5, board);
    expect(moves1_2, [
      Move(Coordinate(1, 2), Coordinate.right, 1, 5),
      Move(Coordinate(0, 3), Coordinate.right, 1, 5),
    ]);
    persistMove(Move(Coordinate(0, 3), Coordinate.right, 1, 3), board);

    /// GH
    final points2 = getPossibleStartingPoints(2, board, words);
    expect(points2, [Coordinate(2, 2), Coordinate(3, 3), Coordinate(2, 4)]);
    // Do not allow word to end near any start point
    expect(getPossibleMoves([Coordinate(0, 5)], 2, 2, board), [
      Move(Coordinate(0, 5), Coordinate.upRight, 2, 2),
      Move(Coordinate(0, 5), Coordinate.right, 2, 2),
    ]);
    persistMove(Move(Coordinate(5, 4), Coordinate.down, 2, 2), board);

    /// Random word
    final points3 = getPossibleStartingPoints(3, board, words);
    expect(points3, [Coordinate(4, 5)]);
    final moves3 = getPossibleMoves(points3, 3, 5, board);
    expect(moves3, [
      Move(Coordinate(4, 5), Coordinate.up, 3, 5),
      Move(Coordinate(4, 5), Coordinate.left, 3, 5),
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
    final board = Board.create(5, 5, 1);
    persistMove(Move(Coordinate(0, 1), Coordinate.right, 0, 2), board);
    persistMove(Move(Coordinate(4, 1), Coordinate.up, 1, 2), board);
    persistMove(Move(Coordinate(4, 4), Coordinate.up, 2, 2), board);
    persistMove(Move(Coordinate(0, 2), Coordinate.right, 3, 3), board);
    final points = getPossibleStartingPoints(4, board, words);
    expect(points, [Coordinate(3, 2), Coordinate(2, 3)]);
  });

  test("Overlap", () {
    /// A start of a word-¹ can not be overlapped
    //   0 1 2 3
    // 0 - A - -
    // 1 - B - -
    // 2 - C - -
    // 3 - - - -
    var words = [Word.from("ABC", 0, false), Word.from("DAB", 1, false)];
    var board = Board.create(6, 6, 1);
    persistMove(Move(Coordinate(1, 0), Coordinate.down, 0, 3), board);
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
    board = Board.create(7, 7, 1);

    /// a.d.e.g
    persistMove(Move(Coordinate(0, 2), Coordinate.right, 0, 4), board);
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
    final board = Board.create(10, 10, 1);
    persistMove(Move(Coordinate(0, 0), Coordinate.right, 0, 1), board);
    final List<Word> words = [
      Word.from("A", 0, false),
      Word.from("abc", 1, false),
      Word.from("b", 2, false),
    ];
    expect(getOverlaps(1, words, board), []);
    persistMove(Move(Coordinate(0, 1), Coordinate.down, 1, 3), board);
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
    final board = Board.create(8, 8, 1);
    board.startMove(Coordinate(0, 2));
    persistMove(Move(Coordinate(0, 2), Coordinate.right, 0, 6), board);
    persistMove(Move(Coordinate(7, 5), Coordinate.upLeft, 1, 6), board);
    // Overlap would be on I if it was allowed
    expect(getOverlaps(2, words, board), []);
  });

  test("Does not allow 2 words to form a diagonal cross", () async {
    //    0 1 2 3 4
    // 0 ⁰A -¹E F *
    // 1  - B x - *
    // 2  - x C - *
    // 3  x - - D *
    // 4  - - - - -
    final words = getWordsInScopeForMaze(BibleVerse.from(text: "ABCD EF Fghi"));
    final board = Board.create(5, 5, 1);
    persistMove(Move(Coordinate(0, 0), Coordinate.downRight, 0, 4), board);
    persistMove(Move(Coordinate(2, 0), Coordinate.right, 1, 2), board);
    final overlaps = getOverlaps(2, words, board);
    expect(overlaps, []);
    final startingPoints = getPossibleStartingPoints(2, board, words);
    final moves = getPossibleMoves(startingPoints, 0, 4, board).map(toString).toList();
    expect(moves, ["(4, 0, 0, 1, 0, 4)"]);
  });

  test("Trim board", () {
    final board = Board.create(10, 10, 1);
    persistMove(Move(Coordinate(1, 2), Coordinate.upRight, 0, 2), board);
    persistMove(Move(Coordinate(2, 3), Coordinate.down, 1, 2), board);
    board.trim();
    expect(board.width, 2);
    expect(board.height, 4);
    expect(board.getAt(0, 1).contains(0, 0), true);
    expect(board.getAt(1, 0).contains(0, 1), true);
    expect(board.getAt(1, 2).contains(1, 0), true);
    expect(board.getAt(1, 3).contains(1, 1), true);
    expect(board.coordinateOf(0, 0), Coordinate(0, 1));
    expect(board.coordinateOf(1, 1), Coordinate(1, 3));
    expect(board.moves[1][0][0], [Coordinate(0, 1), Coordinate(1, 0)]);
    expect(board.moves[2][1][0], [Coordinate(1, 2), Coordinate(1, 3)]);
  });

  testWidgets("Add noise - Overlaps - simple", (WidgetTester tester) async {
    //   0 1 2 3 4 5
    // 0 - - - A - -
    // 1 - - - E F D
    // 2 A B C D - H
    // 3 - - - - - H
    // 4 - - D E A H
    // 5 - - - - - -
    final board = Board.create(6, 6, 1);
    var words = getWordsInScopeForMaze(BibleVerse.from(text: "ABC DEA EFD HHH AED"));
    persistMove(Move(Coordinate(0, 2), Coordinate.right, 0, 3), board);
    persistMove(Move(Coordinate(3, 2), Coordinate.up, 1, 3), board);
    persistMove(Move(Coordinate(3, 1), Coordinate.right, 2, 3), board);
    persistMove(Move(Coordinate(5, 2), Coordinate.down, 3, 3), board);
    persistMove(Move(Coordinate(4, 4), Coordinate.left, 4, 3), board);
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
    final moves = getOverlapNoiseMoves(board, words);
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
    final board = Board.create(6, 5, 1);
    final words = getWordsInScopeForMaze(BibleVerse.from(text: "ABC CI HRDE IC"));
    persistMove(Move(Coordinate(2, 1), Coordinate.downLeft, 0, 3), board);
    persistMove(Move(Coordinate(0, 3), Coordinate.downRight, 1, 2), board);
    persistMove(Move(Coordinate(2, 4), Coordinate.upRight, 2, 4), board);
    persistMove(Move(Coordinate(5, 0), Coordinate.left, 3, 2), board);
    final moves = getOverlapNoiseMoves(board, words);
    expect(moves.map(toString).toList(), [
      "(2, 1, -1, 0, 0, 3)",
      "(0, 1, 0, 1, 0, 3)",
      "(2, 4, 1, 0, 2, 4)",
      "(5, 4, 0, -1, 2, 4)",
    ]);
  });

  test("Outer Forest", () {
    //   0 1 2 3 4 5
    // 0 - - - - - -
    // 1 - A D - - -
    // 2 E - - - - -
    // 3 - - - Z - -
    // 4 - - - - - -
    final board = Board.create(6, 6, 1);
    persistMove(Move(Coordinate(1, 1), Coordinate.right, 0, 2), board);
    persistMove(Move(Coordinate(0, 2), Coordinate.right, 1, 1), board);
    persistMove(Move(Coordinate(3, 4), Coordinate.right, 2, 1), board);
    addEnvironments(board);
    final waters = [
      [
        CellEnv.upLeft,
        CellEnv.none,
        CellEnv.none,
        CellEnv.upRight,
        CellEnv.frontier,
        CellEnv.forest
      ],
      [CellEnv.none, CellEnv.none, CellEnv.none, CellEnv.none, CellEnv.frontier, CellEnv.forest],
      [
        CellEnv.none,
        CellEnv.none,
        CellEnv.none,
        CellEnv.downRight,
        CellEnv.frontier,
        CellEnv.forest
      ],
      [
        CellEnv.none,
        CellEnv.downRight,
        CellEnv.none,
        CellEnv.none,
        CellEnv.upRight,
        CellEnv.frontier
      ],
      [
        CellEnv.frontier,
        CellEnv.frontier,
        CellEnv.none,
        CellEnv.none,
        CellEnv.none,
        CellEnv.frontier
      ],
      [
        CellEnv.forest,
        CellEnv.frontier,
        CellEnv.downLeft,
        CellEnv.none,
        CellEnv.downRight,
        CellEnv.frontier
      ],
    ];
    for (var x = 0; x < board.width; x++) {
      for (var y = 0; y < board.height; y++) {
        expect(board.getAt(x, y).environment, waters[y][x]);
      }
    }
  });

  test("Create the board many times and expect 100% succees", () async {
    final stopAt = 80;
    final verse = BibleVerse.from(
      book: "Jaona",
      bookId: 4,
      chapter: 1,
      verse: 1,
      text: "Ny filazana ny razan'i Jesosy Kristy",
    );
    final now = DateTime.now().millisecondsSinceEpoch;
    for (var i = 0; i < stopAt; i++) {
      // board should not be null
      final board = await createMazeBoard(verse, 1);
      expect(board, isNotNull);
      // all the chars are in the board
      final words = getWordsInScopeForMaze(verse);
      for (var wIndex = 0; wIndex < words.length; wIndex++) {
        final word = words[wIndex];
        for (var cIndex = 0; cIndex < word.length; cIndex++) {
          expect(board.coordinateOf(wIndex, cIndex), isNotNull);
        }
      }
      // trimmed
      expect(board.value[0].where((c) => c.isFilled), isNotEmpty);
      expect(board.value.where((row) => row[0].isFilled), isNotEmpty);
      // have start and end
      expect(board.start, board.coordinateOf(0, 0));
      expect(board.end, board.coordinateOf(6, 5));
    }
    print("֎ Tesed init maze $stopAt times in ${DateTime.now().millisecondsSinceEpoch - now} ms");
  });

  test("Initial revealed state", () {
    final board = Board.create(4, 4, 0);
    persistMove(Move(Coordinate(0, 0), Coordinate.downRight, 0, 2), board);
    board.updateStartEnd([Word.from("AB", 0, false)]);
    expect(initialRevealedState(board), [
      [false, false, false, false],
      [false, false, false, false],
      [false, false, false, false],
      [false, false, false, false],
    ]);
  });

  testWidgets("Initialize maze game", (tester) async {
    final store = newMockedStore();
    final boardFinder = find.byKey(Key("maze_board"));
    await tester.pumpWidget(BibleGame(store));
    await tester.pump(Duration(seconds: 1));
    await tester.tap(find.byKey(Key("game_1")));
    await tester.pump(Duration(seconds: 1));
    simulateMazeRandomGame(store);
    await tester.pump(Duration(seconds: 1));

    await waitForWidget(boardFinder, tester);
    expect(boardFinder, findsOneWidget);
    final board = store.state.maze.board;
    expect(board, isNotNull);
    expect(board.start, isNotNull);
    expect(board.end, isNotNull);
    expect(board.start, board.coordinateOf(0, 0));
    expect(board.end, board.coordinateOf(6, 5));
    expect(store.state.maze.wordsToReveal, [0, 1, 2, 4, 5, 6]);
  });
}
