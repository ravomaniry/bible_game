import 'package:bible_game/app/components/oscillator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Oscillator get y", () {
    final left = Offset(0, 0);
    final right = Offset(100, 0);
    // simple case
    var control = Offset(0, 0);
    expect(getY(0, 0, left, control, right, 0), 0);
    expect(getY(0, 0.25, left, control, right, 5), 5);
    expect(getY(0, 0.5, left, control, right, 0), 0);
    expect(getY(0, 0.75, left, control, right, -5), -5);
    expect(getY(0, 1, left, control, right, 0), 0);

    // Constrained
    expect(getY(5, 0, left, control, right, 6), 1);
    expect(getY(5, 0, left, control, right, -6), -1);

    // Different control point
    control = Offset(60, 40);
    expect(getY(0, 0, left, control, right, 10), 10);
    expect(getY(0, 0.25, left, control, right, 15), 15);
    expect(getY(0, 0.5, left, control, right, 10), 10);
    expect(getY(0, 0.75, left, control, right, 5), 5);
    expect(getY(0, 1, left, control, right, 10), 10);
  });
}
