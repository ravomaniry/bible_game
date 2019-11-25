import 'package:bible_game/models/word.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Copy words", () {
    final original = Word(
      index: 0,
      resolved: false,
      bonus: null,
      chars: [Char(value: "A"), Char(value: "z")],
    );
    expect(
      original.copyWith(resolved: true),
      Word(
        index: 0,
        resolved: true,
        bonus: null,
        chars: [Char(value: "A"), Char(value: "z")],
      ),
    );
    expect(
      original.copyWith(resolved: true, chars: [Char(value: "b")]),
      Word(
        index: 0,
        resolved: true,
        bonus: null,
        chars: [Char(value: "b")],
      ),
    );
    expect(
      original.copyWithChar(1, Char(value: "z", resolved: true)),
      Word(
        index: 0,
        resolved: false,
        bonus: null,
        chars: [Char(value: "A"), Char(value: "z", resolved: true)],
      ),
    );
  });
}
