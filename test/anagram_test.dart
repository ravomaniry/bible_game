import 'package:bible_game/main.dart';
import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/redux/game/actions.dart';
import 'package:bible_game/redux/inventory/actions.dart';
import 'package:bible_game/redux/router/actions.dart';
import 'package:bible_game/redux/router/routes.dart';
import 'package:bible_game/redux/words_in_word/actions.dart';
import 'package:bible_game/redux/words_in_word/anagram_logics.dart';
import 'package:bible_game/redux/words_in_word/state.dart';
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
      text: "ABC DEFG I",
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
    expect(store.state.wordsInWord.wordsToFind.map((w) => w.value), ["ABC", "DEFG"]);

    /// First proposition should be A-B-C or D-E-F-G
    var state = store.state.wordsInWord;
    var slotValues = state.slots.map((c) => c.comparisonValue).toList();
    if (slotValues.length == 3) {
      expect(slotValues, containsAll(["a", "b", "c"]));
    } else {
      expect(slotValues, containsAll(["d", "e", "f", "g"]));
    }

    /// click on slots
    final prevSlots = store.state.wordsInWord.slots;
    await tester.tap(find.byKey(Key("slot_1")));
    await tester.pump();
    await tester.tap(find.byKey(Key("slot_2")));
    await tester.pump();
    state = store.state.wordsInWord;
    expect(state.slots[0], isNotNull);
    expect(state.slots[1], null);
    expect(state.slots[2], null);
    if (state.slots.length == 4) {
      expect(state.slots[3], isNotNull);
    }
    expect(state.proposition[0].comparisonValue, prevSlots[1].comparisonValue);
    expect(state.proposition[1].comparisonValue, prevSlots[2].comparisonValue);

    /// This is not allowed to be proposed as one or two slots are not clicked
    await tester.tap(proposeBtn);
    await tester.pump(Duration(milliseconds: 10));
    state = store.state.wordsInWord;
    expect(state.propositionAnimation, PropositionAnimations.none);
    expect(state.slots.where((x) => x == null).length, 2);
    expect(state.proposition.length, 2);

    /// Propose with true response (propose is allowed when all the slots are empty)
    store.dispatch(UpdateWordsInWordState(state.copyWith(
      proposition: Word.from("DEFG", 2, false).chars,
      slots: [null, null, null, null],
    )));
    await tester.pump(Duration(milliseconds: 10));
    await tester.tap(proposeBtn);
    await tester.pump(Duration(milliseconds: 10));

    state = store.state.wordsInWord;
    expect(state.wordsToFind.map((w) => w.value).toList(), ["ABC"]);
    expect(state.resolvedWords.map((w) => w.value).toList(), ["DEFG"]);
    slotValues = state.slots.map((s) => s.comparisonValue).toList();
    expect(slotValues.length, 3);
    expect(slotValues, containsAll(["a", "b", "c"]));
    expect(store.state.game.inventory.money, 4);

    /// Bonus
    expect(store.state.game.inventory.revealCharBonus2, 1);
    await tester.tap(find.byKey(Key("revealCharBonusBtn_2")));
    await tester.pump();
    expect(store.state.game.inventory.revealCharBonus2, 0);
    expect(store.state.game.verse.words[0].chars.where((c) => c.resolved).length, 2);

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
