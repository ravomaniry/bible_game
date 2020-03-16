import 'package:bible_game/app/game/actions/actions.dart';
import 'package:bible_game/app/inventory/actions/actions.dart';
import 'package:bible_game/app/inventory/reducer/state.dart';
import 'package:bible_game/app/router/actions.dart';
import 'package:bible_game/app/router/routes.dart';
import 'package:bible_game/games/maze/actions/actions.dart';
import 'package:bible_game/games/maze/create/board_utils.dart';
import 'package:bible_game/games/maze/logic/logic.dart';
import 'package:bible_game/games/maze/logic/paths.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/games/maze/models/move.dart';
import 'package:bible_game/games/maze/redux/state.dart';
import 'package:bible_game/main.dart';
import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/bonus.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/test_helpers/matchers.dart';
import 'package:bible_game/test_helpers/store.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  testWidgets("Propose + reveal + path", (tester) async {
    final store = newMockedStore();
    final verse = BibleVerse.from(text: "Abc def dab defgh i dk");
    final board = Board.create(6, 6, 0);
    store.dispatch(UpdateGameVerse(verse));
    store.dispatch(UpdateMazeState(MazeState.emptyState().copyWith(
      words: getWordsInScopeForMaze(verse),
      board: board,
      revealed: initialRevealedState(board),
      wordsToFind: [0, 1, 2, 3, 4, 5],
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
    expect(store.state.maze.wordsToReveal, [0, 1, 2, 3, 4, 5]);

    /// One cell
    store.dispatch(proposeMaze([Coordinate(5, 0)]));
    expect(store.state.game.verse.words[8].resolved, true);
    expect(store.state.game.inventory.money, 1);
    expect(store.state.maze.revealed[0], [false, false, false, false, false, true]);
    expect(store.state.maze.revealed, toHave2(true, 1));
    expect(store.state.maze.wordsToReveal, [0, 1, 2, 3, 5]);

    /// one word
    store.dispatch(proposeMaze([Coordinate(0, 0), Coordinate(0, 1), Coordinate(0, 2)]));
    expect(store.state.game.verse.words[0].resolved, true);
    expect(store.state.game.inventory.money, 4);
    expect(store.state.maze.revealed[0][0], true);
    expect(store.state.maze.revealed[1][0], true);
    expect(store.state.maze.revealed[2][0], true);
    expect(store.state.maze.revealed, toHave2(true, 4));
    expect(store.state.maze.wordsToReveal, [1, 2, 3, 5]);

    /// exceed
    // empty
    store.dispatch(proposeMaze([Coordinate(3, 3), Coordinate(4, 3), Coordinate(5, 3)]));
    expect(store.state.maze.revealed, toHave2(true, 4));
    // filled
    store.dispatch(
      proposeMaze([Coordinate(0, 3), Coordinate(1, 3), Coordinate(2, 3), Coordinate(3, 3)]),
    );
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
    expect(store.state.maze.wordsToReveal, [1, 2, 3]);
    store.dispatch(proposeMaze([Coordinate(4, 3), Coordinate(4, 4), Coordinate(4, 5)]));
    expect(store.state.maze.revealed, toHave2(true, 8));
    expect(store.state.maze.wordsToReveal, [1, 2, 3]);
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
    await tester.pump(Duration(seconds: 21));
  });

  test("Play + Complete + sfx", () {
    final store = newMockedStore();
    final verse = BibleVerse.from(text: "Abc def");
    final board = Board.create(6, 6, 0);
    final words = getWordsInScopeForMaze(verse);
    persistMove(Move(Coordinate(0, 0), Coordinate.right, 0, 3), board);
    persistMove(Move(Coordinate(3, 0), Coordinate.down, 1, 3), board);
    board.updateStartEnd(words);
    store.dispatch(UpdateGameVerse(verse));
    store.dispatch(UpdateMazeState(MazeState.emptyState().copyWith(
      words: words,
      board: board,
      revealed: initialRevealedState(board),
    )));
    store.dispatch(proposeMaze([Coordinate(0, 0), Coordinate(1, 0), Coordinate(2, 0)]));
    expect(store.state.game.isResolved, false);
    verify(store.state.sfx.playShortSuccess()).called(1);
    store.dispatch(proposeMaze([Coordinate(3, 0), Coordinate(3, 1), Coordinate(3, 2)]));
    expect(store.state.game.isResolved, true);
    verify(store.state.sfx.playLongSuccess()).called(1);
  });

  test("getAllPaths", () {
    var moves = [
      MazeMove(Coordinate(0, 1), Coordinate(2, 1), true, true),
      MazeMove(Coordinate(3, 1), Coordinate(3, 0), true, true),
    ];
    expect(getAllPaths(moves, Coordinate(0, 1)), [
      [Coordinate(0, 1), Coordinate(2, 1), Coordinate(3, 1), Coordinate(3, 0)],
    ]);
    // Overlap
    moves = [
      MazeMove(Coordinate(3, 3), Coordinate(1, 3), true, false),
      MazeMove(Coordinate(1, 3), Coordinate(0, 3), false, true),
      MazeMove(Coordinate(5, 4), Coordinate(4, 3), true, true),
      MazeMove(Coordinate(1, 3), Coordinate(3, 5), true, true),
    ];
    expect(getAllPaths(moves, Coordinate(5, 4)), [
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
    expect(getAllPaths(moves, Coordinate(5, 4)), [
      [Coordinate(5, 4), Coordinate(4, 3), Coordinate(3, 3), Coordinate(1, 3), Coordinate(0, 3)],
      [Coordinate(1, 3), Coordinate(3, 5)],
      [Coordinate(1, 4), Coordinate(1, 5)],
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
    expect(getAllPaths(moves, Coordinate(2, 0)), [
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
  });

  test("revealed moves + paths", () {
    // . . . E . .
    // A B C D . .
    // . . I . . .
    // J I H G N .
    // . M K . . M
    // . N . L . .
    var board = Board.create(6, 6, 0);
    var words = getWordsInScopeForMaze(BibleVerse.from(text: "ABC DE IH GHIJ MN IKL"));
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
  });

  testWidgets("Bonus", (tester) async {
    //   ⁰ ¹ ² ³
    // ⁰ A B C .
    // ¹ . . D .
    // ² G F E L
    // ³ H I J K
    final verse = BibleVerse.from(text: "Abc d efg hij kl");
    verse.words[0] = verse.words[0].copyWith(bonus: RevealCharBonus5());
    final words = getWordsInScopeForMaze(verse);

    final board = Board.create(4, 4, 1);
    persistMove(Move(Coordinate(0, 0), Coordinate.right, 0, 3), board);
    persistMove(Move(Coordinate(2, 1), Coordinate.right, 1, 1), board);
    persistMove(Move(Coordinate(2, 2), Coordinate.left, 2, 3), board);
    persistMove(Move(Coordinate(0, 3), Coordinate.right, 3, 3), board);
    persistMove(Move(Coordinate(3, 3), Coordinate.up, 4, 2), board);
    board.updateStartEnd(words);

    final store = newMockedStore();
    final state = MazeState(
      nextId: 1,
      board: board,
      backgrounds: null,
      words: words,
      revealed: initialRevealedState(board),
      wordsToReveal: [0, 2, 3],
      wordsToConfirm: [0, 1, 2, 3],
      confirmed: [],
    );
    await tester.pumpWidget(BibleGame(store));
    await tester.pump(Duration(seconds: 1));
    store.dispatch(UpdateInventory(InventoryState.emptyState().copyWith(
      revealCharBonus1: 1,
      revealCharBonus2: 2,
      revealCharBonus5: 1,
      revealCharBonus10: 1,
    )));
    store.dispatch(UpdateGameVerse(verse));
    store.dispatch(UpdateMazeState(state));
    store.dispatch(GoToAction(Routes.maze));

    /// propose word with bonus inside
    store.dispatch(proposeMaze([Coordinate(0, 0), Coordinate(1, 0), Coordinate(2, 0)]));
    expect(store.state.maze.revealed, toHave2(true, 5));
    expect(store.state.maze.newlyRevealed.length, 5);
    expect(store.state.maze.confirmed.length, 1);
    expect(
      store.state.maze.wordsToReveal,
      anyOf([
        [2],
        [3]
      ]),
    );
    expect(store.state.maze.wordsToConfirm, [0, 1, 2, 3]);
    expect(store.state.maze.hints.length, 2);
    expect(store.state.maze.paths.length, 1);
    expect(store.state.game.verse.words[0].resolved, true);
    expect(
      [...store.state.game.verse.words[4].chars, ...store.state.game.verse.words[6].chars],
      toPass<Char>((c) => c.resolved, 2),
    );
    await tester.pump(Duration(seconds: 1));
    expect(store.state.maze.newlyRevealed, []);

    /// Reveal partially
    await tester.pump();
    await tester.tap(find.byKey(Key("revealCharBonusBtn_1")));
    await tester.pump();
    expect(store.state.maze.revealed, toHave2(true, 6));
    expect(store.state.game.inventory.revealCharBonus1, 0);
    expect(store.state.maze.wordsToConfirm, [0, 1, 2, 3]);
    expect(store.state.maze.hints.length, 3);
    expect(
      store.state.maze.wordsToReveal,
      anyOf([
        [2],
        [3]
      ]),
    );
    expect(
      [...store.state.game.verse.words[4].chars, ...store.state.game.verse.words[6].chars],
      toPass<Char>((c) => c.resolved, 3),
    );
    await tester.pump(Duration(seconds: 1));

    /// Reveal except last char
    await tester.pump();
    await tester.tap(find.byKey(Key("revealCharBonusBtn_2")));
    await tester.pump();
    expect(store.state.maze.revealed, toHave2(true, 7));
    expect(store.state.maze.confirmed.length, 1);
    expect(store.state.game.inventory.revealCharBonus2, 1);
    expect(store.state.maze.wordsToConfirm, [0, 1, 2, 3]);
    expect(store.state.maze.wordsToReveal, []);
    expect(store.state.maze.newlyRevealed, isNotEmpty);
    expect(store.state.maze.hints.length, 4);
    await tester.pump(Duration(seconds: 1));
    expect(store.state.maze.newlyRevealed, isEmpty);

    /// Unused bonus
    await tester.pump();
    await tester.tap(find.byKey(Key("revealCharBonusBtn_2")));
    await tester.pump();
    expect(store.state.maze.revealed, toHave2(true, 7));
    expect(store.state.game.inventory.revealCharBonus2, 1);
    await tester.pump(Duration(seconds: 1));

    /// Click on useful bonus
    await tester.tap(find.byKey(Key("revealCharBonusBtn_10")));
    await tester.pump();
    expect(store.state.maze.revealed, toHave2(true, 7));
    expect(store.state.maze.confirmed.length, 3);
    expect(store.state.game.inventory.revealCharBonus10, 0);
    expect(store.state.maze.hints.length, 4);
    await tester.pump(Duration(seconds: 1));

    /// Reveal word -> remove revealed from hint
    store.dispatch(proposeMaze([Coordinate(2, 2), Coordinate(1, 2), Coordinate(0, 2)]));
    expect(store.state.maze.hints.length, 2);
    expect(store.state.maze.revealed, toHave2(true, 8));
    await tester.pump(Duration(seconds: 1));
  });
}
