import 'package:bible_game/games/maze/components/canvas/selection.dart';
import 'package:bible_game/games/maze/components/tap_handler.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Selection Rects", () {
    expect(getSelectedCells(Offset(12, 12), Offset(12, 12)), [Coordinate(0, 0)]);
    expect(getSelectedCells(Offset(12, 12), Offset(132, 36)), isNull);
    expect(getSelectedCells(Offset(84, 36), Offset(36, 108)), isNull);
    expect(
      getSelectedRects(getSelectedCells(Offset(12, 12), Offset(12, 12))),
      [createRoundedRect(0, 0, 24, 24)],
    );
    expect(
      getSelectedRects(getSelectedCells(Offset(36, 36), Offset(36, 36))),
      [createRoundedRect(24, 24, 48, 48)],
    );
    // Horizontal
    final horizontal = [
      createRoundedRect(24, 24, 48, 48),
      createRoundedRect(48, 24, 72, 48),
      createRoundedRect(72, 24, 96, 48),
      createRoundedRect(96, 24, 120, 48),
    ];
    expect(getSelectedRects(getSelectedCells(Offset(36, 36), Offset(108, 36))), horizontal);
    expect(
      getSelectedRects(getSelectedCells(Offset(108, 36), Offset(36, 36))),
      horizontal.reversed.toList(),
    );

    // Vertical
    final vertical = [
      createRoundedRect(48, 24, 72, 48),
      createRoundedRect(48, 48, 72, 72),
      createRoundedRect(48, 72, 72, 96),
    ];
    expect(getSelectedRects(getSelectedCells(Offset(60, 36), Offset(60, 84))), vertical);
    expect(
      getSelectedRects(getSelectedCells(Offset(60, 84), Offset(60, 36))),
      vertical.reversed.toList(),
    );

    final diagonal1 = [
      createRoundedRect(24, 24, 48, 48),
      createRoundedRect(48, 48, 72, 72),
      createRoundedRect(72, 72, 96, 96),
    ];
    expect(
      getSelectedRects(getSelectedCells(Offset(36, 36), Offset(84, 84))),
      diagonal1,
    );
    expect(
      getSelectedRects(getSelectedCells(Offset(84, 84), Offset(36, 36))),
      diagonal1.reversed.toList(),
    );
    final diagonal2 = [
      createRoundedRect(0, 72, 24, 96),
      createRoundedRect(24, 48, 48, 72),
      createRoundedRect(48, 24, 72, 48),
    ];
    expect(getSelectedRects(getSelectedCells(Offset(12, 84), Offset(60, 36))), diagonal2);
    expect(
      getSelectedRects(getSelectedCells(Offset(60, 36), Offset(12, 84))),
      diagonal2.reversed.toList(),
    );
  });
}
