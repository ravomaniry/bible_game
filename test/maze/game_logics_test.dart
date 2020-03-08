import 'package:bible_game/app/game/actions/actions.dart';
import 'package:bible_game/games/maze/actions/actions.dart';
import 'package:bible_game/games/maze/create/board_utils.dart';
import 'package:bible_game/games/maze/create/create_board.dart';
import 'package:bible_game/games/maze/logic/logic.dart';
import 'package:bible_game/games/maze/logic/paths.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/games/maze/models/move.dart';
import 'package:bible_game/games/maze/redux/state.dart';
import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/test_helpers/matchers.dart';
import 'package:bible_game/test_helpers/store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Propose + reveal + path", () {
    final store = newMockedStore();
    final verse = BibleVerse.from(text: "Abc def dab defgh i dk");
    final board = Board.create(6, 6, 0);
    store.dispatch(UpdateGameVerse(verse));
    store.dispatch(UpdateMazeState(MazeState.emptyState().copyWith(
      wordsToFind: getWordsInScopeForMaze(verse),
      board: board,
      revealed: initialRevealedState(board),
    )));

    //   ⁰ ¹ ² ³ ⁴ ⁵
    // ⁰ A⁰. . . . i⁴
    // ¹ b a d². h .
    // ² c . . g . .
    // ³¹d e f k d⁵.
    // ⁴ . e . i⁴e .
    // ⁵ d³. . . f .
    persistMove(Move(Coordinate(0, 0), Coordinate.down, 0, 3), board);
    persistMove(Move(Coordinate(0, 3), Coordinate.right, 1, 3), board);
    persistMove(Move(Coordinate(4, 3), Coordinate.down, 1, 3), board);
    persistMove(Move(Coordinate(2, 1), Coordinate.left, 2, 3), board);
    persistMove(Move(Coordinate(0, 5), Coordinate.upRight, 3, 5), board);
    persistMove(Move(Coordinate(5, 0), Coordinate.upRight, 4, 1), board);
    persistMove(Move(Coordinate(3, 4), Coordinate.upRight, 4, 1), board);
    persistMove(Move(Coordinate(4, 3), Coordinate.left, 5, 2), board);
    board.updateStartEnd(getWordsInScopeForMaze(verse));

    /// Invalid ones
    store.dispatch(proposeMaze([Coordinate(0, 0)]));
    expect(store.state.maze.revealed, toBeAll2(false));
    expect(store.state.maze.revealed, toHave2(true, 0));
    store.dispatch(proposeMaze([Coordinate(1, 0)]));
    expect(store.state.maze.revealed, toBeAll2(false));
    store.dispatch(proposeMaze([Coordinate(0, 1), Coordinate(1, 1), Coordinate(2, 1)]));
    expect(store.state.maze.revealed, toBeAll2(false));

    /// One cell
    store.dispatch(proposeMaze([Coordinate(5, 0)]));
    expect(store.state.maze.revealed[0], [false, false, false, false, false, true]);
    expect(store.state.maze.revealed, toHave2(true, 1));

    /// one word
    store.dispatch(proposeMaze([Coordinate(0, 0), Coordinate(0, 1), Coordinate(0, 2)]));
    expect(store.state.maze.revealed[0][0], true);
    expect(store.state.maze.revealed[1][0], true);
    expect(store.state.maze.revealed[2][0], true);
    expect(store.state.maze.revealed, toHave2(true, 4));

    /// exceed
    // empty
    store.dispatch(proposeMaze([Coordinate(3, 3), Coordinate(4, 3), Coordinate(5, 3)]));
    expect(store.state.maze.revealed, toHave2(true, 4));
    // filled
    store.dispatch(proposeMaze([
      Coordinate(0, 3),
      Coordinate(1, 3),
      Coordinate(2, 3),
      Coordinate(3, 3),
    ]));
    expect(store.state.maze.revealed, toHave2(true, 4));
    store.dispatch(proposeMaze([
      Coordinate(0, 3),
      Coordinate(1, 3),
      Coordinate(2, 3),
      Coordinate(3, 3),
      Coordinate(4, 3),
    ]));
    expect(store.state.maze.revealed, toHave2(true, 4));
    store.dispatch(proposeMaze([Coordinate(4, 3), Coordinate(3, 4)]));
    expect(store.state.maze.revealed, toHave2(true, 4));

    /// overlap
    // at 0
    store.dispatch(proposeMaze([Coordinate(4, 3), Coordinate(3, 3)]));
    expect(store.state.maze.revealed, toHave2(true, 6));
    store.dispatch(proposeMaze([Coordinate(4, 3), Coordinate(4, 4), Coordinate(4, 5)]));
    expect(store.state.maze.revealed, toHave2(true, 8));
    // at the middle
    store.dispatch(proposeMaze([
      Coordinate(0, 5),
      Coordinate(1, 4),
      Coordinate(2, 3),
      Coordinate(3, 2),
      Coordinate(4, 1),
    ]));
    expect(store.state.maze.revealed, toHave2(true, 13));
    // at the end
    store.dispatch(proposeMaze([Coordinate(0, 3), Coordinate(1, 3), Coordinate(2, 3)]));
    expect(store.state.maze.revealed, toHave2(true, 15));
  });

  test("assemblePaths", () {
    var moves = [
      MazeMove(Coordinate(0, 1), Coordinate(2, 1), true, true),
      MazeMove(Coordinate(3, 1), Coordinate(3, 0), true, true),
    ];
    expect(assemblePaths(moves, Coordinate(0, 1), Coordinate(2, 2)), [
      [Coordinate(0, 1), Coordinate(2, 1), Coordinate(3, 1), Coordinate(3, 0)],
    ]);
    // Overlap
    moves = [
      MazeMove(Coordinate(3, 3), Coordinate(1, 3), true, false),
      MazeMove(Coordinate(1, 3), Coordinate(0, 3), false, true),
      MazeMove(Coordinate(5, 4), Coordinate(4, 3), true, true),
      MazeMove(Coordinate(1, 3), Coordinate(3, 5), true, true),
    ];
    expect(assemblePaths(moves, Coordinate(0, 0), Coordinate(5, 5)), [
      [Coordinate(0, 0)],
      [Coordinate(5, 4), Coordinate(4, 3), Coordinate(3, 3), Coordinate(1, 3), Coordinate(3, 5)],
      [Coordinate(1, 3), Coordinate(0, 3)],
    ]);
    moves = [
      MazeMove(Coordinate(1, 3), Coordinate(3, 5), true, true),
      MazeMove(Coordinate(3, 3), Coordinate(1, 3), true, false),
      MazeMove(Coordinate(1, 3), Coordinate(0, 3), false, true),
      MazeMove(Coordinate(1, 4), Coordinate(1, 5), true, true),
      MazeMove(Coordinate(5, 4), Coordinate(4, 3), true, true),
    ];
    expect(assemblePaths(moves, Coordinate(0, 1), Coordinate(5, 5)), [
      [Coordinate(0, 1)],
      [Coordinate(5, 4), Coordinate(4, 3), Coordinate(3, 3), Coordinate(1, 3), Coordinate(3, 5)],
      [Coordinate(1, 3), Coordinate(0, 3)],
      [Coordinate(1, 4), Coordinate(1, 5)],
    ]);
    expect(assemblePaths(moves, Coordinate(5, 4), Coordinate(0, 3)), [
      [Coordinate(5, 4), Coordinate(4, 3), Coordinate(3, 3), Coordinate(1, 3), Coordinate(0, 3)],
    ]);
    // Multiple overlap a.b.c.d | b.g.g | b.g.g | gh | gh | xx | yy
    // . . a . .
    // g g b g g
    // x h c h y
    // x . d . y
    moves = [
      MazeMove(Coordinate(2, 0), Coordinate(2, 1), true, false),
      MazeMove(Coordinate(2, 1), Coordinate(2, 3), false, true),
      MazeMove(Coordinate(2, 1), Coordinate(1, 1), true, false),
      MazeMove(Coordinate(1, 1), Coordinate(0, 1), false, true),
      MazeMove(Coordinate(1, 1), Coordinate(1, 2), true, true),
      MazeMove(Coordinate(2, 1), Coordinate(3, 1), true, false),
      MazeMove(Coordinate(3, 1), Coordinate(4, 1), false, true),
      MazeMove(Coordinate(3, 1), Coordinate(3, 2), true, true),
      MazeMove(Coordinate(0, 2), Coordinate(0, 3), true, true),
      MazeMove(Coordinate(4, 2), Coordinate(4, 3), true, true),
    ];
    expect(assemblePaths(moves, Coordinate(2, 0), Coordinate(1, 3)), [
      [
        Coordinate(2, 0),
        Coordinate(2, 1),
        Coordinate(3, 1),
        Coordinate(3, 2),
        Coordinate(4, 2),
        Coordinate(4, 3),
      ],
      [Coordinate(2, 1), Coordinate(2, 3)],
      [Coordinate(2, 1), Coordinate(1, 1), Coordinate(1, 2), Coordinate(0, 2), Coordinate(0, 3)],
      [Coordinate(1, 1), Coordinate(0, 1)],
      [Coordinate(3, 1), Coordinate(4, 1)],
    ]);
    expect(assemblePaths(moves, Coordinate(2, 0), Coordinate(4, 3)), [
      [
        Coordinate(2, 0),
        Coordinate(2, 1),
        Coordinate(3, 1),
        Coordinate(3, 2),
        Coordinate(4, 2),
        Coordinate(4, 3)
      ],
    ]);
    expect(assemblePaths(moves, Coordinate(2, 0), Coordinate(2, 3)), [
      [Coordinate(2, 0), Coordinate(2, 1), Coordinate(2, 3)],
    ]);
    expect(assemblePaths(moves, Coordinate(2, 0), Coordinate(4, 1)), [
      [Coordinate(2, 0), Coordinate(2, 1), Coordinate(3, 1), Coordinate(4, 1)],
    ]);
    // From the middle
    expect(assemblePaths(moves, Coordinate(2, 1), Coordinate(4, 1)), [
      [Coordinate(2, 1), Coordinate(3, 1), Coordinate(4, 1)],
    ]);
  });

  test("Join start to end", () {
    var paths = [
      [Coordinate(1, 1), Coordinate(2, 1), Coordinate(3, 1)],
      [Coordinate(2, 1), Coordinate(4, 1)],
      [Coordinate(4, 1), Coordinate(5, 1), Coordinate(6, 1)],
    ];
    expect(joinStartToEnd(paths, Coordinate(2, 1), Coordinate(2, 1)), isNull);
    expect(
      joinStartToEnd(paths, Coordinate(1, 1), Coordinate(3, 1)),
      [Coordinate(1, 1), Coordinate(2, 1), Coordinate(3, 1)],
    );
    expect(
      joinStartToEnd(paths, Coordinate(1, 1), Coordinate(4, 1)),
      [Coordinate(1, 1), Coordinate(2, 1), Coordinate(4, 1)],
    );
    expect(
      joinStartToEnd(paths, Coordinate(2, 1), Coordinate(6, 1)),
      [Coordinate(2, 1), Coordinate(4, 1), Coordinate(5, 1), Coordinate(6, 1)],
    );
    paths = [
      [Coordinate(0, 0), Coordinate(0, 1), Coordinate(0, 2)],
      [Coordinate(1, 1), Coordinate(0, 1), Coordinate(0, 3)],
    ];
    expect(
      joinStartToEnd(paths, Coordinate(0, 0), Coordinate(0, 3)),
      [Coordinate(0, 0), Coordinate(0, 1), Coordinate(0, 3)],
    );

    paths = [
      [
        Coordinate(0, 5),
        Coordinate(0, 1),
        Coordinate(1, 0),
        Coordinate(2, 0),
        Coordinate(2, 2),
        Coordinate(3, 2),
      ],
      [
        Coordinate(1, 2),
        Coordinate(2, 2),
        Coordinate(2, 7),
        Coordinate(1, 7),
        Coordinate(0, 7),
        Coordinate(0, 10),
        Coordinate(1, 10),
        Coordinate(3, 8),
        Coordinate(3, 9),
        Coordinate(4, 10),
        Coordinate(5, 10),
        Coordinate(5, 7),
      ],
      [Coordinate(2, 7), Coordinate(2, 8)],
      [Coordinate(3, 5), Coordinate(3, 8)],
      [
        Coordinate(4, 12),
        Coordinate(5, 13),
        Coordinate(6, 13),
        Coordinate(7, 14),
        Coordinate(10, 11),
        Coordinate(14, 15),
        Coordinate(16, 15),
        Coordinate(16, 14),
        Coordinate(17, 13),
        Coordinate(18, 13),
        Coordinate(16, 11),
        Coordinate(15, 10),
        Coordinate(15, 9),
        Coordinate(14, 10),
        Coordinate(14, 2),
      ],
      [Coordinate(14, 14), Coordinate(14, 10), Coordinate(13, 11), Coordinate(13, 5)],
      [Coordinate(5, 10), Coordinate(5, 11), Coordinate(3, 11)],
      [
        Coordinate(6, 11),
        Coordinate(5, 11),
        Coordinate(5, 13),
        Coordinate(6, 13),
        Coordinate(6, 16),
      ],
      [Coordinate(9, 10), Coordinate(10, 11)],
      [Coordinate(14, 15), Coordinate(16, 17), Coordinate(17, 18), Coordinate(17, 19)],
      [Coordinate(20, 15), Coordinate(17, 18), Coordinate(19, 20), Coordinate(19, 22)],
      [Coordinate(19, 20), Coordinate(21, 22)],
      [Coordinate(9, 10), Coordinate(11, 10)],
      [Coordinate(9, 10), Coordinate(9, 7)],
      [Coordinate(9, 10), Coordinate(7, 12)],
      [Coordinate(16, 11), Coordinate(17, 10)],
      [Coordinate(2, 12), Coordinate(0, 10)],
      [Coordinate(7, 14), Coordinate(8, 15)],
      [Coordinate(10, 13), Coordinate(8, 15)],
      [Coordinate(13, 13), Coordinate(13, 11)],
      [Coordinate(14, 17), Coordinate(16, 17)],
    ];
    final joined = joinStartToEnd(paths, Coordinate(0, 5), Coordinate(14, 2));
    expect(joined.length, isNotNull);
    expect(joined.first, Coordinate(0, 5));
    expect(joined.last, Coordinate(14, 2));
  });

  test("revealed moves + paths", () {
    // . . . E . .
    // A B C D . .
    // . . I . . .
    // J I H G N .
    // . M K . . M
    // . N . L . .
    final board = Board.create(6, 6, 0);
    final words = getWordsInScopeForMaze(BibleVerse.from(text: "ABC DE IH GHIJ MN IKL"));
    persistMove(Move(Coordinate(0, 1), Coordinate.right, 0, 3), board);
    persistMove(Move(Coordinate(3, 1), Coordinate.up, 1, 2), board);
    persistMove(Move(Coordinate(2, 2), Coordinate.down, 2, 2), board);
    persistMove(Move(Coordinate(3, 3), Coordinate.left, 3, 4), board);
    persistMove(Move(Coordinate(5, 4), Coordinate.upLeft, 4, 2), board);
    persistMove(Move(Coordinate(1, 4), Coordinate.down, 4, 2), board);
    persistMove(Move(Coordinate(1, 3), Coordinate.downRight, 5, 3), board);
    board.updateStartEnd(words);
    // one full word
    var revealed = [
      [false, false, false, false, false, false],
      [true, true, true, false, false, false],
      [false, false, false, false, false, false],
      [false, false, false, false, false, false],
      [false, false, false, false, false, false],
      [false, false, false, false, false, false],
    ];
    expect(getRevealedMoves(board, revealed, words), [
      MazeMove(Coordinate(0, 1), Coordinate(2, 1), true, true),
    ]);
    expect(getRevealedPaths(board, revealed, words), [
      [Coordinate(0, 1), Coordinate(2, 1)]
    ]);
    // 0 & 1
    revealed = [
      [false, false, false, true, false, false],
      [true, true, true, true, false, false],
      [false, false, false, false, false, false],
      [false, false, false, false, false, false],
      [false, false, false, false, false, false],
      [false, false, false, false, false, false],
    ];
    expect(getRevealedMoves(board, revealed, words), [
      MazeMove(Coordinate(0, 1), Coordinate(2, 1), true, true),
      MazeMove(Coordinate(3, 1), Coordinate(3, 0), true, true),
    ]);
    expect(getRevealedPaths(board, revealed, words), [
      [Coordinate(0, 1), Coordinate(2, 1), Coordinate(3, 1), Coordinate(3, 0)],
    ]);
    // Overlap single direction ( 0 & 1 & 3)
    revealed = [
      [false, false, false, true, false, false],
      [true, true, true, true, false, false],
      [false, false, false, false, false, false],
      [true, true, true, true, false, false],
      [false, false, false, false, false, false],
      [false, false, false, false, false, false],
    ];
    expect(getRevealedMoves(board, revealed, words), [
      MazeMove(Coordinate(0, 1), Coordinate(2, 1), true, true),
      MazeMove(Coordinate(3, 1), Coordinate(3, 0), true, true),
      MazeMove(Coordinate(3, 3), Coordinate(0, 3), true, true),
    ]);
    expect(getRevealedPaths(board, revealed, words), [
      [Coordinate(0, 1), Coordinate(2, 1), Coordinate(3, 1), Coordinate(3, 0)],
      [Coordinate(3, 3), Coordinate(0, 3)],
    ]);

    // Append at start || end
    revealed = [
      [false, false, false, true, false, false],
      [true, true, true, true, false, false],
      [false, false, false, false, false, false],
      [true, true, true, true, true, false],
      [false, true, true, false, false, true],
      [false, true, false, true, false, false],
    ];
    expect(getRevealedMoves(board, revealed, words), [
      MazeMove(Coordinate(0, 1), Coordinate(2, 1), true, true),
      MazeMove(Coordinate(3, 1), Coordinate(3, 0), true, true),
      MazeMove(Coordinate(1, 3), Coordinate(3, 5), true, true),
      MazeMove(Coordinate(3, 3), Coordinate(1, 3), true, false),
      MazeMove(Coordinate(1, 3), Coordinate(0, 3), false, true),
      MazeMove(Coordinate(1, 4), Coordinate(1, 5), true, true),
      MazeMove(Coordinate(5, 4), Coordinate(4, 3), true, true),
    ]);
    expect(getRevealedPaths(board, revealed, words), [
      [Coordinate(0, 1), Coordinate(2, 1), Coordinate(3, 1), Coordinate(3, 0)],
      [Coordinate(5, 4), Coordinate(4, 3), Coordinate(3, 3), Coordinate(1, 3), Coordinate(3, 5)],
      [Coordinate(1, 3), Coordinate(0, 3)],
      [Coordinate(1, 4), Coordinate(1, 5)],
    ]);

    // Completed + dual direction overlap
    revealed = [
      [false, false, false, true, false, false],
      [true, true, true, true, false, false],
      [false, false, true, false, false, false],
      [true, true, true, true, false, false],
      [false, false, true, false, false, false],
      [false, false, false, true, false, false],
    ];
    expect(getRevealedMoves(board, revealed, words), [
      MazeMove(Coordinate(0, 1), Coordinate(2, 1), true, true),
      MazeMove(Coordinate(3, 1), Coordinate(3, 0), true, true),
      MazeMove(Coordinate(2, 2), Coordinate(2, 3), true, true),
      MazeMove(Coordinate(1, 3), Coordinate(3, 5), true, true),
      MazeMove(Coordinate(3, 3), Coordinate(2, 3), true, false),
      MazeMove(Coordinate(2, 3), Coordinate(1, 3), false, false),
      MazeMove(Coordinate(1, 3), Coordinate(0, 3), false, true),
    ]);
    // To verify if this test should pass
//    expect(getRevealedPaths(board, revealed, words), [
//      [
//        Coordinate(0, 1),
//        Coordinate(2, 1),
//        Coordinate(2, 2),
//        Coordinate(2, 3),
//        Coordinate(1, 3),
//        Coordinate(3, 5),
//      ],
//    ]);
  });

  test("Always resolvable", () async {
    final iterations = 40;
    final verse = BibleVerse.from(
      bookId: 4,
      book: "Jaona",
      chapter: 1,
      verse: 1,
      text: "Tamin'ny voalohany ny Teny, ary ny Teny tao amin''Andriamanitra, "
          "ary ny Teny dia Andriamanitra.",
    );
    final words = getWordsInScopeForMaze(verse);
    for (var i = 0; i < iterations; i++) {
      print(i);
      final board = await createMazeBoard(verse, 1);
      final revealed = initialRevealedState(board);
      board.updateStartEnd(words);
      for (var y = 0; y < board.height; y++) {
        for (var x = 0; x < board.width; x++) {
          revealed[y][x] = true;
        }
      }
      final paths = getRevealedPaths(board, revealed, words);
      expect([board.start, board.end], toHave1(null, 0));
      expect(paths.length, 1);
      expect(paths[0].first, board.start);
      expect(paths[0].last, board.end);
    }
  });
}
