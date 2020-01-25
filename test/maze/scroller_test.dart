import 'package:bible_game/games/maze/components/scroller.dart';
import 'package:flutter/cupertino.dart';
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
}
