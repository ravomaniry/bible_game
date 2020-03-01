import 'package:bible_game/app/game/actions/actions.dart';
import 'package:bible_game/games/maze/actions/actions.dart';
import 'package:bible_game/games/maze/create/board_utils.dart';
import 'package:bible_game/games/maze/logic/logic.dart';
import 'package:bible_game/games/maze/logic/paths.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/games/maze/models/move.dart';
import 'package:bible_game/games/maze/redux/state.dart';
import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/test_helpers/matchers.dart';
import 'package:bible_game/test_helpers/store.dart';
import 'package:bible_game/utils/pair.dart';
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

  test("revealed moves + paths", () {
    // . . . E . .
    // A B C D . .
    // . . I . . .
    // J I H G . .
    // . . K . . .
    // . . . L . .
    final board = Board.create(6, 6, 0);
    final words = getWordsInScopeForMaze(BibleVerse.from(text: "ABC DE IH GHIJ IKL"));
    persistMove(Move(Coordinate(0, 1), Coordinate.right, 0, 3), board);
    persistMove(Move(Coordinate(3, 0), Coordinate.down, 1, 2), board);
    persistMove(Move(Coordinate(2, 2), Coordinate.down, 2, 2), board);
    persistMove(Move(Coordinate(3, 3), Coordinate.left, 3, 4), board);
    persistMove(Move(Coordinate(1, 3), Coordinate.downRight, 4, 3), board);
    board.updateStartEnd(words);
    // one full word
    var revealed = [
      [false, false, false, false, false],
      [true, true, true, false, false],
      [false, false, false, false, false],
      [false, false, false, false, false],
      [false, false, false, false, false],
      [false, false, false, false, false],
    ];
    expect(getRevealedMoves(board, revealed, words), [Pair(Coordinate(0, 1), Coordinate(2, 1))]);
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
      Pair(Coordinate(3, 0), Coordinate(3, 1)),
      Pair(Coordinate(0, 1), Coordinate(2, 1)),
    ]);
    expect(getRevealedPaths(board, revealed, words), [
      [Coordinate(3, 0), Coordinate(3, 1), Coordinate(2, 1), Coordinate(0, 1)],
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
      Pair(Coordinate(3, 0), Coordinate(3, 1)),
      Pair(Coordinate(0, 1), Coordinate(2, 1)),
      Pair(Coordinate(3, 3), Coordinate(0, 3)),
    ]);
    expect(getRevealedPaths(board, revealed, words), [
      [Coordinate(3, 0), Coordinate(3, 1), Coordinate(2, 1), Coordinate(0, 1)],
      [Coordinate(3, 3), Coordinate(0, 3)],
    ]);
    // Completed + dual direction overlap
    revealed = [
      [false, false, false, true, false],
      [true, true, true, true, false],
      [false, false, true, false, false],
      [true, true, true, true, false],
      [false, false, true, false, false],
      [false, false, false, true, false],
    ];
    expect(getRevealedMoves(board, revealed, words), [
      Pair(Coordinate(3, 0), Coordinate(3, 1)),
      Pair(Coordinate(0, 1), Coordinate(2, 1)),
      Pair(Coordinate(2, 2), Coordinate(2, 3)),
      Pair(Coordinate(1, 3), Coordinate(3, 5)),
      Pair(Coordinate(3, 3), Coordinate(2, 3)),
      Pair(Coordinate(2, 3), Coordinate(1, 3)),
      Pair(Coordinate(1, 3), Coordinate(0, 3)),
    ]);
    expect(getRevealedPaths(board, revealed, words), [
      [
        Coordinate(0, 1),
        Coordinate(2, 1),
        Coordinate(2, 2),
        Coordinate(2, 3),
        Coordinate(1, 3),
        Coordinate(3, 5),
      ],
    ]);
  });
}
