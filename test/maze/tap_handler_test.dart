import 'package:bible_game/games/maze/components/tap_handler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Snap selection", () {
    final a = Offset(10, 10);
    final b = Offset(40, 40);
    final c = Offset(100, 10);
    expect(snapCursor(a, b), Offset(0, 0));
    expect(snapCursor(b, a), Offset(48, 48));
    expect(snapCursor(a, c), Offset(0, 0));
    expect(snapCursor(c, a), Offset(120, 0));
    expect(snapCursor(b, c), Offset(24, 48));
    expect(snapCursor(c, b), Offset(120, 0));
  });
}
