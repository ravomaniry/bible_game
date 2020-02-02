import 'package:bible_game/app/game/actions/actions.dart';
import 'package:bible_game/app/router/actions.dart';
import 'package:bible_game/app/router/routes.dart';
import 'package:bible_game/games/maze/actions/actions.dart';
import 'package:bible_game/games/maze/actions/board_utils.dart';
import 'package:bible_game/games/maze/components/scroller.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/redux/state.dart';
import 'package:bible_game/main.dart';
import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/test_helpers/store.dart';
import 'package:bible_game/utils/pair.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Scroll limit", () {
    Size boardSize = Size(100, 200);
    Size containerSize = Size(100, 100);
    Size current = Size(0, 0);
    Size offsets = getNextOffsets(Size(10, 10), Size(0, 0), boardSize, null);
    expect(offsets, null);
    // right 10, down 10 => null
    expect(getNextOffsets(Size(10, 10), current, boardSize, containerSize), null);
    // left 10 => null
    expect(getNextOffsets(Size(-10, 0), current, boardSize, containerSize), null);
    // down 10, right 10, down 10, left 10 => down 10
    expect(getNextOffsets(Size(10, -10), current, boardSize, containerSize), Size(0, -10));
    expect(getNextOffsets(Size(-10, -10), current, boardSize, containerSize), Size(0, -10));
    // Over Scroll
    expect(getNextOffsets(Size(0, -1000), current, boardSize, containerSize), Size(0, -100));

    /// Scroll to the middle
    boardSize = Size(200, 220);
    current = Size(-50, -50);
    // Allow scroll to all direction (20 tested)
    // up
    expect(getNextOffsets(Size(0, -20), current, boardSize, containerSize), Size(-50, -70));
    expect(getNextOffsets(Size(0, -200), current, boardSize, containerSize), Size(-50, -120));
    // upRight
    expect(getNextOffsets(Size(20, -20), current, boardSize, containerSize), Size(-30, -70));
    expect(getNextOffsets(Size(200, -200), current, boardSize, containerSize), Size(0, -120));
    // right
    expect(getNextOffsets(Size(20, 0), current, boardSize, containerSize), Size(-30, -50));
    expect(getNextOffsets(Size(200, 0), current, boardSize, containerSize), Size(0, -50));
    // rightDown
    expect(getNextOffsets(Size(20, 20), current, boardSize, containerSize), Size(-30, -30));
    expect(getNextOffsets(Size(200, 200), current, boardSize, containerSize), Size(0, 0));
    // down
    expect(getNextOffsets(Size(0, 20), current, boardSize, containerSize), Size(-50, -30));
    expect(getNextOffsets(Size(0, 200), current, boardSize, containerSize), Size(-50, 0));
    // leftDown
    expect(getNextOffsets(Size(-20, 20), current, boardSize, containerSize), Size(-70, -30));
    expect(getNextOffsets(Size(-200, 200), current, boardSize, containerSize), Size(-100, 0));
    // left
    expect(getNextOffsets(Size(-20, 0), current, boardSize, containerSize), Size(-70, -50));
    expect(getNextOffsets(Size(-200, 0), current, boardSize, containerSize), Size(-100, -50));
    // upLeft
    expect(getNextOffsets(Size(-20, -20), current, boardSize, containerSize), Size(-70, -70));
    expect(getNextOffsets(Size(-200, -200), current, boardSize, containerSize), Size(-100, -120));

    /// Container is bigger than board
    boardSize = Size(100, 100);
    containerSize = Size(120, 80);
    current = Size(0, 0);
    expect(getNextOffsets(Size(0, -40), current, boardSize, containerSize), Size(0, -20));
    containerSize = Size(80, 150);
    expect(getNextOffsets(Size(-10, -20), current, boardSize, containerSize), Size(-10, 0));
    containerSize = Size(120, 120);
    expect(getNextOffsets(Size(-10, -10), current, boardSize, containerSize), null);
  });

  test("on screen elements", () {
    Board board = Board.create(7, 5, 1);
    Size containerSize = Size(50, 74);
    Size origin = Size(0, 0);
    expect(getOnScreenLimit(origin, board, containerSize), Pair(Size(0, 0), Size(3, 4)));
    origin = Size(-20, -20);
    expect(getOnScreenLimit(origin, board, containerSize), Pair(Size(0, 0), Size(3, 4)));
    origin = Size(-24, -20);
    expect(getOnScreenLimit(origin, board, containerSize), Pair(Size(1, 0), Size(4, 4)));
    origin = Size(-50, -26);
    expect(getOnScreenLimit(origin, board, containerSize), Pair(Size(2, 1), Size(5, 5)));
    containerSize = Size(1000, 1000);
    expect(getOnScreenLimit(origin, board, containerSize), Pair(Size(2, 1), Size(7, 5)));
  });

  testWidgets("Scroll and propose", (tester) async {
    // This height output 300x460 (12.5 x 15)
    tester.binding.window.physicalSizeTestValue = Size(300, 507);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    final double yOffset = 507.0 - 460;
    final board = Board.create(20, 20, 1); // 480, 480
    board..set(2, 0, 0, 0)..set(2, 1, 0, 2)..set(2, 2, 0, 2);
    final verse =
        BibleVerse.from(text: "Jesosy nitomany", bookId: 4, book: "Jaona", chapter: 11, verse: 33);
    final store = newMockedStore();
    await tester.pumpWidget(BibleGame(store));
    await tester.pump(Duration(seconds: 1));
    store.dispatch(GoToAction(Routes.maze));
    store.dispatch(UpdateGameVerse(verse));
    store.dispatch(UpdateMazeState(MazeState(
      nextId: 1,
      board: board,
      backgrounds: null,
      wordsToFind: getWordsInScopeForMaze(verse),
    )));
    await tester.pump(Duration(seconds: 1));
    // render and should display correctly
    expect(find.byKey(Key("maze_board")), findsOneWidget);
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

    /// SCROLL
    // Tap on 10,10 and drag 20px to the left
    final positionedFinder = find.byKey(Key("board_positioned"));
    var gesture = await tester.startGesture(Offset(4, 4 + yOffset), pointer: 5);
    // left -10 goes to (-10, 0)
    await gesture.moveBy(Offset(-10, 0));
    await tester.pump();
    Positioned positioned = positionedFinder.evaluate().single.widget;
    expect(positioned.top, 0);
    expect(positioned.left, -10);
    // left 20, up 20 goes to (0, 0)
    await gesture.moveBy(Offset(20, 20));
    await tester.pump();
    positioned = positionedFinder.evaluate().single.widget;
    expect(positioned.top, 0);
    expect(positioned.left, 0);
    // (0, 0) + (-100, -100)
    await gesture.moveBy(Offset(-100, -100));
    await tester.pump();
    positioned = positionedFinder.evaluate().single.widget;
    expect(positioned.top, -20);
    expect(positioned.left, -100);

    await gesture.up();
  });
}
