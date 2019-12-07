import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/bonus.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/config/state.dart';
import 'package:bible_game/redux/inventory/state.dart';
import 'package:bible_game/redux/inventory/use_bonus_action.dart';
import 'package:bible_game/redux/main_reducer.dart';
import 'package:bible_game/redux/router/routes.dart';
import 'package:bible_game/redux/words_in_word/actions.dart';
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
          config: ConfigState(screenWidth: 100),
          dba: null,
          explorer: null,
          inventory: InventoryState.emptyState(),
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

  test("Find nearest element", () {
    final list = [10, 11, 12, 13, 14, 15];
    final validator = (int value) => value % 3 == 0;
    expect(findNearestElement(list, 3, validator), 2);
    expect(findNearestElement(list, 0, validator), 2);
    expect(findNearestElement(list, 3, (int value) => value % 5 == 0), 5);
    expect(findNearestElement(list, 5, (value) => value % 2 == 0), 4);
  });

  test("updateVerseBasedOnBonus", () {
    final verse = BibleVerse.from(text: "Jesosy no fiainana");
    final store = Store<AppState>(
      mainReducer,
      middleware: [thunkMiddleware],
      initialState: AppState(
          assetBundle: null,
          config: ConfigState(screenWidth: 100),
          dba: null,
          route: Routes.wordsInWord,
          explorer: null,
          inventory: InventoryState.emptyState(),
          wordsInWord: WordsInWordState.emptyState().copyWith(
            verse: BibleVerse.from(text: "Jesosy no fiainana"),
          )),
    );
    final bonus = RevealCharBonus(3, 0);
    store.dispatch(UseBonus(bonus, false).thunk);
    final charsBefore = verse.words
        .where(
          (w) => !w.isSeparator && !w.resolved,
        )
        .map((w) => w.chars)
        .reduce((a, b) => [...a, ...b]);
    final charsAfter = store.state.wordsInWord.verse.words
        .where((w) => !w.isSeparator && !w.resolved)
        .map((w) => w.chars)
        .reduce((a, b) => [...a, ...b]);
    expect(charsBefore.where((c) => c.resolved).length, 0);
    expect(charsAfter.where((c) => c.resolved).length, 3);
  });

  test("useBonus", () {
    final store = Store<AppState>(
      mainReducer,
      middleware: [thunkMiddleware],
      initialState: AppState(
        assetBundle: null,
        config: ConfigState(screenWidth: 100),
        dba: null,
        route: Routes.wordsInWord,
        explorer: null,
        wordsInWord: WordsInWordState.emptyState().copyWith(),
        inventory: InventoryState.emptyState().copyWith(
          revealCharBonus1: 10,
          revealCharBonus2: 20,
          revealCharBonus5: 50,
          revealCharBonus10: 100,
        ),
      ),
    );
    final verse = BibleVerse.from(text: "ABCDE EFGHI HIJKL MNOPQ RSTUV");
    store.dispatch(receiveVerse(verse, store.state.wordsInWord));
    store.dispatch(initializeWordsInWordState);
    var unrevealed = store.state.wordsInWord.verse.words
        .map((x) => x.chars.where((c) => !c.resolved).length)
        .reduce((a, b) => a + b);
    print(unrevealed);
  });
}
