import 'package:bible_game/main.dart';
import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/app/game/actions/actions.dart';
import 'package:bible_game/app/inventory/actions/actions.dart';
import 'package:bible_game/app/router/actions.dart';
import 'package:bible_game/app/router/routes.dart';
import 'package:bible_game/games/words_in_word/actions/action_creators.dart';
import 'package:bible_game/games/anagram/actions/logic.dart';
import 'package:bible_game/games/words_in_word/actions/cells_action.dart';
import 'package:bible_game/test_helpers/store.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets("Anagram: full flow", (WidgetTester tester) async {
    final store = newMockedStore();
    final verse = BibleVerse.from(
      book: "A",
      bookId: 1,
      chapter: 1,
      verse: 1,
      text: "AB ABC DEFG I",
    );
    final proposeBtn = find.byKey(Key("proposeBtn"));

    store.dispatch(UpdateGameVerse(verse));
    store.dispatch(UpdateInventory(store.state.game.inventory.copyWith(
      revealCharBonus2: 1,
    )));
    store.dispatch(GoToAction(Routes.anagram));
    store.dispatch(initializeAnagram());
    // set hard bonuses values
    final wordsToFind = store.state.wordsInWord.wordsToFind;
    store.dispatch(UpdateWordsInWordState(store.state.wordsInWord.copyWith(
      wordsToFind: wordsToFind.map((w) => w.removeBonus()).toList(),
    )));
    store.dispatch(UpdateGameVerse(verse.copyWith(
      words: verse.words.map((w) => w.removeBonus()).toList(),
    )));

    await tester.pumpWidget(BibleGame(store));
    await tester.pump(Duration(milliseconds: 10));
    // theme is tested in game navigation test
    /// Words to find
    expect(store.state.wordsInWord.wordsToFind.map((w) => w.value).toList(), ["AB", "ABC", "DEFG"]);

    /// First proposition should be: A-B or A-B-C or D-E-F-G
    var state = store.state.wordsInWord;
    var slotValues = state.slots.map((c) => c.comparisonValue).toList();
    if (slotValues.length == 2) {
      expect(slotValues, containsAll(["a", "b"]));
    } else if (slotValues.length == 3) {
      expect(slotValues, containsAll(["a", "b", "c"]));
    } else {
      expect(slotValues, containsAll(["d", "e", "f", "g"]));
    }

    /// Tap on slots
    store.dispatch(UpdateWordsInWordState(store.state.wordsInWord.copyWith(
      slots: Word.from("ABC", 0, false).chars,
      slotsBackup: Word.from("ABC", 0, false).chars,
    )));
    store.dispatch(recomputeSlotsIndexes());
    await tester.pump();
    await tester.tap(find.byKey(Key("slot_0")));
    await tester.pump();
    await tester.tap(find.byKey(Key("slot_1")));
    await tester.pump();
    expect(store.state.wordsInWord.slots, [null, null, Char(value: "C", comparisonValue: "c")]);
    expect(store.state.wordsInWord.proposition, Word.from("AB", 0, false).chars);

    /// Propose with partial correct response - do nothing
    await tester.tap(proposeBtn);
    await tester.pump();
    expect(store.state.wordsInWord.proposition, []);
    expect(store.state.wordsInWord.wordsToFind.length, 3);
    expect(store.state.wordsInWord.slots, Word.from("ABC", 0, false).chars);

    /// Propose true response and resolve AB
    store.dispatch(UpdateWordsInWordState(store.state.wordsInWord.copyWith(
      slots: Word.from("BA", 0, false).chars,
      slotsBackup: Word.from("BA", 0, false).chars,
    )));
    store.dispatch(recomputeSlotsIndexes());
    await tester.pump();
    await tester.tap(find.byKey(Key("slot_1")));
    await tester.pump();
    await tester.tap(find.byKey(Key("slot_0")));
    await tester.pump();
    await tester.tap(proposeBtn);
    await tester.pump();
    expect(store.state.wordsInWord.wordsToFind.length, 2);
    expect(store.state.wordsInWord.proposition, []);
    expect(store.state.game.inventory.money, 2);

    /// Propose and resolve D-E-F-G => only A-B-C is left
    store.dispatch(UpdateWordsInWordState(store.state.wordsInWord.copyWith(
      proposition: Word.from("DEFG", 2, false).chars,
      slots: [null, null, null, null],
      slotsBackup: Word.from("DEFG", 2, false).chars,
    )));
    store.dispatch(recomputeSlotsIndexes());
    await tester.pump();
    await tester.tap(proposeBtn);
    await tester.pump();

    state = store.state.wordsInWord;
    expect(state.wordsToFind.map((w) => w.value).toList(), ["ABC"]);
    expect(state.resolvedWords.map((w) => w.value).toList(), ["AB", "DEFG"]);
    slotValues = state.slots.map((s) => s.comparisonValue).toList();
    expect(slotValues.length, 3);
    expect(state.slotsBackup.length, 3);
    expect(slotValues, containsAll(["a", "b", "c"]));
    expect(store.state.game.inventory.money, 6);

    /// Bonus
    expect(store.state.game.inventory.revealCharBonus2, 1);
    await tester.tap(find.byKey(Key("revealCharBonusBtn_2")));
    await tester.pump();
    expect(store.state.game.inventory.revealCharBonus2, 0);
    expect(store.state.game.verse.words[2].chars.where((c) => c.resolved).length, 2);

    /// Complete the game
    store.dispatch(UpdateWordsInWordState(state.copyWith(
      proposition: Word.from("ABC", 2, false).chars,
    )));
    await tester.pump(Duration(milliseconds: 10));
    await tester.tap(proposeBtn);
    await tester.pump(Duration(milliseconds: 10));
    expect(store.state.game.isResolved, true);
  });
}
