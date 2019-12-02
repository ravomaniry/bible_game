import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/main_reducer.dart';
import 'package:bible_game/redux/words_in_word/logics.dart';
import 'package:bible_game/redux/words_in_word/state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

void main() {
  test("fillSlots", () {
    // Different letters
    List<Char> slots = [null, null, null, null, null, null];
    List<Char> filled = [];
    var words = [
      Word.from("Na", 0, false),
      Word.from("Ito", 1, false),
      Word.from("e", 1, false),
    ];
    filled = fillSlots(slots, words);
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

    // Empty slots after filling
    slots = [...Word.from("JESOSY", 0, false).chars, null];
    words = [
      Word.from("jesosy", 0, false),
      Word.from("tia", 1, false),
      Word.from("ny", 2, false),
    ];
    filled = fillSlots(slots, words);
    filled.sort((a, b) => a.value.codeUnitAt(0) - b.value.codeUnitAt(0));
    expect(filled, Word.from("EJNOSSY", 0, false).chars);

    // Not enough space
    slots = [...Word.from("AAIZ", 0, false).chars, null];
    words = [
      Word.from("jesosy", 0, false),
      Word.from("teny", 1, false),
      Word.from("ny", 2, false),
    ];
    filled = fillSlots(slots, words);
    filled.sort((a, b) => a.value.codeUnitAt(0) - b.value.codeUnitAt(0));
    expect(filled, Word.from("AAINY", 0, false).chars);

    // Take the shortest additional word
    slots = [null, null, null, null, null];
    words = [
      Word.from("ABCD", 0, false),
      Word.from("ABCDEFG", 0, false),
      Word.from("HIJKLM", 0, false),
    ];
    filled = fillSlots(slots, words);
    filled.sort((a, b) => a.value.codeUnitAt(0) - b.value.codeUnitAt(0));
    final isOk = listEquals(filled, Word.from("ABCDE", 0, false).chars) ||
        listEquals(filled, Word.from("ABCDF", 0, false).chars) ||
        listEquals(filled, Word.from("ABCDG", 0, false).chars);
    expect(isOk, true);
  });

  test("Shuffle slots", () async {
    final slots = [...Word.from("ADC", 0, false).chars, null, null];
    final store = Store<AppState>(mainReducer,
        middleware: [thunkMiddleware],
        initialState: AppState(
          assetBundle: null,
          config: null,
          dba: null,
          explorer: null,
          wordsInWord: WordsInWordState(
            cells: [],
            proposition: Word.from("DE", 0, false).chars,
            slots: slots,
            slotsBackup: Word.from("ADCDE", 0, false).chars,
            verse: BibleVerse.from(text: "Aza menatra"),
            wordsToFind: [Word.from("Aza", 0, false), Word.from("menatra", 2, false)],
          ),
        ));
    store.dispatch(shuffleSlotsAction);
    expect(store.state.wordsInWord.slots == slots, false);
    expect(store.state.wordsInWord.slotsBackup, containsAll(Word.from("ADCDE", 0, false).chars));
    expect(store.state.wordsInWord.slots, containsAll(Word.from("ADC", 0, false).chars));
    store.dispatch(proposeWordsInWord);
    expect(store.state.wordsInWord.slotsBackup, containsAll(Word.from("ADCDE", 0, false).chars));
    expect(store.state.wordsInWord.slots, containsAll(Word.from("ADCDE", 0, false).chars));
    expect(store.state.wordsInWord.proposition, []);
  });
}
