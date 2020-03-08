import 'package:bible_game/app/game/actions/actions.dart';
import 'package:bible_game/games/maze/actions/actions.dart';
import 'package:bible_game/games/maze/components/maze.dart';
import 'package:bible_game/games/maze/create/board_utils.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/games/maze/models/move.dart';
import 'package:bible_game/games/maze/redux/state.dart';
import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/test_helpers/positioned.dart';
import 'package:bible_game/test_helpers/spy.dart';
import 'package:bible_game/test_helpers/store.dart';
import 'package:bible_game/test_helpers/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets("Snap & select to right word", (tester) async {
    final spy = Spy();
    final store = newMockedStore();
    final yOffset = 73.0;
    final drag = getDragDispatcher(tester, 0, yOffset);
    final verse = BibleVerse.from(
      text: "Abc",
      book: "Jaona",
      chapter: 1,
      bookId: 4,
      verse: 1,
    );
    final words = getWordsInScopeForMaze(verse);
    final board = Board.create(5, 5, 1);
    persistMove(Move(Coordinate(0, 0), Coordinate.downRight, 0, 3), board);
    board.updateStartEnd(words);
    // store preparation
    store.dispatch(UpdateGameVerse(verse));
    store.dispatch(UpdateMazeState(MazeState.emptyState().copyWith(
      board: board,
      wordsToFind: words,
      revealed: initialRevealedState(board),
    )));

    /// Go!
    await tester.pumpWidget(TestableWithStore(
      store: store,
      child: MazeController(spy.one),
    ));
    // one cell
    await drag(20, 20, 10, 10);
    expect(spy, toBeCalledTimes(1));
    expect(
      spy,
      toBeCalledWith([
        [Coordinate(0, 0)]
      ]),
    );
    // 3 cells
    await drag(10, 10, 60, 70);
    expect(
      spy,
      toBeCalledWith([
        [Coordinate(0, 0), Coordinate(1, 1), Coordinate(2, 2)]
      ]),
    );
    await drag(70, 70, 26, 26);
    expect(
      spy,
      toBeCalledWith([
        [Coordinate(2, 2), Coordinate(1, 1)]
      ]),
    );
    // Not starting at word cell
    spy.clear();
    await drag(25, 10, 40, 40);
    expect(spy, toBeCalledTimes(0));
    // Outside of the canvas
    spy.clear();
    await drag(50, 50, 200, 200);
    expect(
      spy,
      toBeCalledWith([
        [Coordinate(2, 2)]
      ]),
    );
  });
}
