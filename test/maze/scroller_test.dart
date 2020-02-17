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
import 'package:bible_game/test_helpers/positioned.dart';
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
    Offset current = Offset(0, 0);
    var offset = getNextOffset(Offset(10, 10), current, boardSize, null);
    expect(offset, null);
    // right 10, down 10 => null
    expect(getNextOffset(Offset(10, 10), current, boardSize, containerSize), null);
    // left 10 => null
    expect(getNextOffset(Offset(-10, 0), current, boardSize, containerSize), null);
    // down 10, right 10, down 10, left 10 => down 10
    expect(getNextOffset(Offset(10, -10), current, boardSize, containerSize), Offset(0, -10));
    expect(getNextOffset(Offset(-10, -10), current, boardSize, containerSize), Offset(0, -10));
    // Over Scroll
    expect(getNextOffset(Offset(0, -1000), current, boardSize, containerSize), Offset(0, -100));

    /// Scroll to the middle
    boardSize = Size(200, 220);
    current = Offset(-50, -50);
    // Allow scroll to all direction (20 tested)
    // up
    expect(getNextOffset(Offset(0, -20), current, boardSize, containerSize), Offset(-50, -70));
    expect(getNextOffset(Offset(0, -200), current, boardSize, containerSize), Offset(-50, -120));
    // upRight
    expect(getNextOffset(Offset(20, -20), current, boardSize, containerSize), Offset(-30, -70));
    expect(getNextOffset(Offset(200, -200), current, boardSize, containerSize), Offset(0, -120));
    // right
    expect(getNextOffset(Offset(20, 0), current, boardSize, containerSize), Offset(-30, -50));
    expect(getNextOffset(Offset(200, 0), current, boardSize, containerSize), Offset(0, -50));
    // rightDown
    expect(getNextOffset(Offset(20, 20), current, boardSize, containerSize), Offset(-30, -30));
    expect(getNextOffset(Offset(200, 200), current, boardSize, containerSize), Offset(0, 0));
    // down
    expect(getNextOffset(Offset(0, 20), current, boardSize, containerSize), Offset(-50, -30));
    expect(getNextOffset(Offset(0, 200), current, boardSize, containerSize), Offset(-50, 0));
    // leftDown
    expect(getNextOffset(Offset(-20, 20), current, boardSize, containerSize), Offset(-70, -30));
    expect(getNextOffset(Offset(-200, 200), current, boardSize, containerSize), Offset(-100, 0));
    // left
    expect(getNextOffset(Offset(-20, 0), current, boardSize, containerSize), Offset(-70, -50));
    expect(getNextOffset(Offset(-200, 0), current, boardSize, containerSize), Offset(-100, -50));
    // upLeft
    expect(getNextOffset(Offset(-20, -20), current, boardSize, containerSize), Offset(-70, -70));
    expect(
        getNextOffset(Offset(-200, -200), current, boardSize, containerSize), Offset(-100, -120));

    /// Container is bigger than board
    boardSize = Size(100, 100);
    containerSize = Size(120, 80);
    current = Offset(0, 0);
    expect(getNextOffset(Offset(0, -40), current, boardSize, containerSize), Offset(0, -20));
    containerSize = Size(80, 150);
    expect(getNextOffset(Offset(-10, -20), current, boardSize, containerSize), Offset(-10, 0));
    containerSize = Size(120, 120);
    expect(getNextOffset(Offset(-10, -10), current, boardSize, containerSize), null);
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

  testWidgets("Scroll", (tester) async {
    // This height output 300x460 (12.5x15)
    tester.binding.window.physicalSizeTestValue = Size(300, 507);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    final double yOffset = 507.0 - 460;
    final drag = getDragDispatcher(tester, 0, yOffset);
    final board = Board.create(20, 20, 1); // 480x480
    final verse = BibleVerse.from(
      text: "Jesosy nitomany",
      bookId: 4,
      book: "Jaona",
      chapter: 11,
      verse: 33,
    );
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

    /// SCROLL
    // Tap
    final finder = find.byKey(Key("board_positioned"));
    var gesture = await tester.startGesture(Offset(100, 100 + yOffset), pointer: 5);
    // Drag
    await gesture.moveTo(Offset(90, 100 + yOffset));
    await tester.pump();
    expect(positionOf(finder), Offset(-10, 0));
    // Drag
    await gesture.moveTo(Offset(250, 120 + yOffset));
    await tester.pump();
    expect(positionOf(finder), Offset(0, 0));
    // Drag + exceed max
    await gesture.moveTo(Offset(50, 50 + yOffset));
    await tester.pump();
    expect(positionOf(finder), Offset(-180, -48));
    await gesture.up();
    await tester.pump();

    /// Ignore scroll outside the container
    await drag(10, 10, -1, 1);
    expect(positionOf(finder), Offset(-180, -48));
    await drag(10, 10, 10, 500);
    expect(positionOf(finder), Offset(-180, -48));
  });

  testWidgets("Screen edge autoscroll + propose", (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = Size(300, 507);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    final double yOffset = 507.0 - 460;
    final drag = getDragDispatcher(tester, 0, yOffset);
    final board = Board.create(22, 22, 1); // 528x528
    board..set(3, 3, 0, 0)..set(4, 4, 0, 1)..set(5, 5, 0, 2);
    final verse = BibleVerse.from(
      text: "Jesosy nitomany",
      bookId: 4,
      book: "Jaona",
      chapter: 11,
      verse: 33,
    );
    final store = newMockedStore();
    final finder = find.byKey(Key("board_positioned"));
    // render
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
    // render and should display correctly
    await tester.pump(Duration(seconds: 1));
    expect(find.byKey(Key("maze_board")), findsOneWidget);

    // A cell is tapped => moving the pointer do not scroll
    var gesture = await tester.startGesture(Offset(80, 80 + yOffset));
    await gesture.moveTo(Offset(200, 80 + yOffset));
    await tester.pump();
    expect(positionOf(finder), Offset(0, 0));

    /// container size is 300x432
    /// RIGHT (animation duration is 600ms)
    // + concurrent calls
    await gesture.moveTo(Offset(280, 80 + yOffset));
    await tester.pump(Duration(milliseconds: 1));
    await tester.pump(Duration(milliseconds: 200));
    expect(positionOf(finder), Offset(-16, 0));
    await gesture.moveTo(Offset(205, 80 + yOffset));
    await tester.pump(Duration(milliseconds: 100));
    await gesture.moveTo(Offset(210, 80 + yOffset));
    await tester.pump(Duration(milliseconds: 500));
    expect(positionOf(finder), Offset(-48, 0));
    await gesture.up();
    await tester.pump(Duration(seconds: 1));

    /// UP RIGHT
    // only left move is allowed
    await drag(32, 80, 280, 40);
    await tester.pump(animationDuration);
    expect(positionOf(finder), Offset(-96, 0));
    // Both axis allowed
    await drag(96, 98, 96, 2);
    expect(positionOf(finder), Offset(-96, -96));
    await drag(24.0 * 5 - 96, 24.0 * 5 - 96, 280, 40);
    await tester.pump(animationDuration);
    expect(positionOf(finder), Offset(-144, -48));
    // Constrained
    await drag(0, 0, 120, 24);
    expect(positionOf(finder), Offset(-24, -24));
    await drag(24.0 * 4, 24.0 * 4, 24, 24);
    await tester.pump(animationDuration);
    expect(positionOf(finder), Offset(0, 0));

    /// UP
    await drag(96, 72, 0, 0);
    expect(positionOf(finder), Offset(-96, -72));
    // possible
    await drag(24.0 * 5 - 96, 24.0 * 5 - 72, 120, 24);
    await tester.pump(animationDuration);
    expect(positionOf(finder), Offset(-96, -24));
    // constrained
    await drag(24.0 * 5 - 96, 24.0 * 4, 120, 24);
    await tester.pump(animationDuration);
    expect(positionOf(finder), Offset(-96, 0));
    // impossible
    await drag(24.0 * 5 - 96, 24.0 * 5, 120, 24);
    await tester.pump(animationDuration);
    expect(positionOf(finder), Offset(-96, 0));

    /// UP LEFT
    await drag(0, 172, 24, 100);
    expect(positionOf(finder), Offset(-72, -72));
    // all possible
    await drag(24.0 * 5 - 72, 24.0 * 5 - 72, 10, 10);
    await tester.pump(animationDuration);
    expect(positionOf(finder), Offset(-24, -24));
    // constrained
    await drag(24.0 * 4, 24.0 * 4, 10, 10);
    await tester.pump(animationDuration);
    expect(positionOf(finder), Offset(0, 0));
    // impossible
    await drag(24.0 * 5, 24.0 * 5, 10, 10);
    await tester.pump(animationDuration);
    expect(positionOf(finder), Offset(0, 0));

    /// LEFT
    await drag(72, 0, 0, 0);
    expect(positionOf(finder), Offset(-72, 0));
    await drag(24.0 * 5 - 72, 24.0 * 5, 10, 10);
    await tester.pump(animationDuration);
    expect(positionOf(finder), Offset(-24, 0));

    /// DOWN LEFT (container height = 432; board height = 528) => max scroll = 96
    await drag(0, 24, 0, 0);
    expect(positionOf(finder), Offset(-24, -24));
    // Down possible, left constrained
    await drag(24.0 * 4, 24.0 * 4, 10, 430);
    await tester.pump(animationDuration);
    expect(positionOf(finder), Offset(0, -72));
    // Down constrained
    await drag(24.0 * 5, 24.0 * 2, 10, 430);
    await tester.pump(animationDuration);
    expect(positionOf(finder), Offset(0, -96));

    /// DOWN
    await drag(0, 120, 0, 168);
    expect(positionOf(finder), Offset(0, -48));
    // possible
    await drag(24.0 * 5, 24.0 * 3, 80, 430);
    await tester.pump(animationDuration);
    expect(positionOf(finder), Offset(0, -96));
    // impossible
    await drag(24.0 * 5, 24.0, 80, 430);
    await tester.pump(animationDuration);
    expect(positionOf(finder), Offset(0, -96));
  });
}
