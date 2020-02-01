import 'package:bible_game/games/maze/components/path.dart';
import 'package:bible_game/games/maze/components/tap_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Selection Rects", () {
    expect(getSelectedCells(Offset(0, 0), Offset(120, 48)), isNull);
    expect(getSelectedCells(Offset(24.0 * 3, 24), Offset(24, 24.0 * 4)), isNull);
    expect(
      getSelectedRects(getSelectedCells(Offset(0, 0), Offset(0, 0))),
      [createRoundedRect(0, 0, 24, 24)],
    );
    expect(
      getSelectedRects(getSelectedCells(Offset(24, 24), Offset(24, 24))),
      [createRoundedRect(24, 24, 48, 48)],
    );
    // Horizontal
    final horizontal = [
      createRoundedRect(24, 24, 48, 48),
      createRoundedRect(24.0 * 2, 24, 24.0 * 3, 48),
      createRoundedRect(24.0 * 3, 24, 24.0 * 4, 48),
      createRoundedRect(24.0 * 4, 24, 24.0 * 5, 48),
    ];
    expect(getSelectedRects(getSelectedCells(Offset(24, 24), Offset(120, 24))), horizontal);
    expect(getSelectedRects(getSelectedCells(Offset(24, 24), Offset(120, 48))), horizontal);
    expect(
      getSelectedRects(getSelectedCells(Offset(120, 48), Offset(24, 24))),
      horizontal.reversed.toList(),
    );
    expect(
      getSelectedRects(getSelectedCells(Offset(120, 24), Offset(24, 48))),
      horizontal.reversed.toList(),
    );

    // Vertical
    final vertical = [
      createRoundedRect(48, 24.0 * 1, 72, 24.0 * 2),
      createRoundedRect(48, 24.0 * 2, 72, 24.0 * 3),
      createRoundedRect(48, 24.0 * 3, 72, 24.0 * 4),
    ];
    expect(getSelectedRects(getSelectedCells(Offset(48, 24), Offset(48, 24.0 * 4))), vertical);
    expect(getSelectedRects(getSelectedCells(Offset(48, 24), Offset(72, 24.0 * 4))), vertical);
    expect(getSelectedRects(getSelectedCells(Offset(72, 24), Offset(48, 24.0 * 4))), vertical);

    // Diagonal
    final diagonal1 = [
      createRoundedRect(24.0 * 1, 24.0 * 1, 24.0 * 2, 24.0 * 2),
      createRoundedRect(24.0 * 2, 24.0 * 2, 24.0 * 3, 24.0 * 3),
      createRoundedRect(24.0 * 3, 24.0 * 3, 24.0 * 4, 24.0 * 4),
    ];
    expect(
      getSelectedRects(getSelectedCells(Offset(24, 24), Offset(24.0 * 4, 24.0 * 4))),
      diagonal1,
    );
    expect(
      getSelectedRects(getSelectedCells(Offset(24.0 * 4, 24.0 * 4), Offset(24, 24))),
      diagonal1.reversed.toList(),
    );
    final diagonal2 = [
      createRoundedRect(0, 72, 24, 96),
      createRoundedRect(24, 48, 48, 72),
      createRoundedRect(48, 24, 72, 48),
    ];
    expect(getSelectedRects(getSelectedCells(Offset(0, 96), Offset(72, 24))), diagonal2);
    expect(
      getSelectedRects(getSelectedCells(Offset(72, 24), Offset(0, 96))),
      diagonal2.reversed.toList(),
    );
  });
}
