import 'package:bible_game/models/word.dart';
import 'package:bible_game/redux/words_in_word/logics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("fillSlots", () {
    // Different letters
    List<Char> slots = [null, null, null, null, null, null];
    var words = [
      Word.from("Na", 0, false),
      Word.from("Ito", 1, false),
      Word.from("e", 1, false),
    ];
    var filled = fillSlots(slots, words);
    filled.sort((a, b) => a.value.codeUnitAt(0) - b.value.codeUnitAt(0));
    expect(filled, Word.from("AEINOT", 0, true).chars);

    // No place
    slots = [
      Char(value: "A", comparisonValue: "a"),
      Char(value: "B", comparisonValue: "b"),
      null,
      null,
    ];
    words = [Word.from("Zaza", 0, false), Word.from("bala", 0, false)];
    filled = fillSlots(slots, words);
    filled.sort((a, b) => a.value.codeUnitAt(0) - b.value.codeUnitAt(0));
    expect(filled, Word.from("AABL", 0, false).chars);

    // Repetitions
    slots = [null, null, null, null, null, null, null];
    words = [
      Word.from("aza", 0, false),
      Word.from("zaza", 0, false),
    ];
    filled = fillSlots(slots, words);
    filled.sort((a, b) => a.value.codeUnitAt(0) - b.value.codeUnitAt(0));
    expect(filled, Word.from("AAAAZZZ", 0, false).chars);
  });
}
