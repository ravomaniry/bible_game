import 'package:bible_game/models/word.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Copy words", () {
    final original = Word(
      index: 0,
      resolved: false,
      bonus: null,
      value: "Az",
      chars: [
        Char(value: "A", comparisonValue: "a"),
        Char(value: "z", comparisonValue: "z"),
      ],
    );
    expect(
      original.copyWith(resolved: true),
      Word(
        index: 0,
        resolved: true,
        bonus: null,
        value: "Az",
        chars: [
          Char(value: "A", comparisonValue: "a"),
          Char(value: "z", comparisonValue: "z"),
        ],
      ),
    );
    expect(
      original.copyWith(resolved: true, chars: [Char(value: "b", comparisonValue: "b")]),
      Word(
        index: 0,
        resolved: true,
        bonus: null,
        value: "b",
        chars: [Char(value: "b", comparisonValue: "b")],
      ),
    );
    expect(
      original.copyWithChar(1, Char(value: "z", comparisonValue: "z", resolved: true)),
      Word(
        index: 0,
        resolved: false,
        bonus: null,
        value: "Az",
        chars: [
          Char(value: "A", comparisonValue: "a"),
          Char(value: "z", comparisonValue: "z", resolved: true),
        ],
      ),
    );
  });
}
