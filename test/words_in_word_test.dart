import 'package:bible_game/main.dart';
import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/bonus.dart';
import 'package:bible_game/models/cell.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/config/actions.dart';
import 'package:bible_game/redux/config/state.dart';
import 'package:bible_game/redux/editor/state.dart';
import 'package:bible_game/redux/explorer/state.dart';
import 'package:bible_game/redux/game/actions.dart';
import 'package:bible_game/redux/game/state.dart';
import 'package:bible_game/redux/inventory/actions.dart';
import 'package:bible_game/redux/inventory/state.dart';
import 'package:bible_game/redux/main_reducer.dart';
import 'package:bible_game/redux/router/actions.dart';
import 'package:bible_game/redux/router/routes.dart';
import 'package:bible_game/redux/themes/themes.dart';
import 'package:bible_game/redux/words_in_word/actions.dart';
import 'package:bible_game/redux/words_in_word/cells_action.dart';
import 'package:bible_game/redux/words_in_word/logics.dart';
import 'package:bible_game/redux/words_in_word/state.dart';
import 'package:bible_game/test_helpers/asset_bundle.dart';
import 'package:bible_game/test_helpers/db_adapter_mock.dart';
import 'package:bible_game/test_helpers/sfx_mock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

void main() {
  test("Compute cells and slots", () async {
    final store = Store<AppState>(
      mainReducer,
      middleware: [thunkMiddleware],
      initialState: AppState(
        sfx: SfxMock(),
        editor: EditorState(),
        theme: AppColorTheme(),
        game: GameState.emptyState(),
        dba: DbAdapterMock.withDefaultValues(),
        assetBundle: AssetBundleMock.withDefaultValue(),
        explorer: ExplorerState(),
        config: ConfigState.initialState(),
      ),
    );
    // reminder: cellWidth = 24 | screenWidth -= 10
    store.dispatch(UpdateScreenWidth(205));
    store.dispatch(UpdateGameVerse(
      BibleVerse.from(
        book: "",
        bookId: 1,
        chapter: 1,
        verse: 1,
        text: "Ny filazana ny razan'i Jesosy Kristy",
      ),
    ));
    store.dispatch(GoToAction(Routes.wordsInWord));
    store.dispatch(initializeWordsInWordState);
    expect(store.state.config.screenWidth, 205);
    await Future.delayed(Duration(milliseconds: 10));
    final expectedCells = [
      [Cell(0, 0), Cell(0, 1), Cell(1, 0)],
      [Cell(2, 0), Cell(2, 1), Cell(2, 2), Cell(2, 3), Cell(2, 4), Cell(2, 5), Cell(2, 6), Cell(2, 7)],
      [Cell(4, 0), Cell(4, 1), Cell(5, 0)],
      [Cell(6, 0), Cell(6, 1), Cell(6, 2), Cell(6, 3), Cell(6, 4), Cell(7, 0), Cell(8, 0), Cell(9, 0)],
      [Cell(10, 0), Cell(10, 1), Cell(10, 2), Cell(10, 3), Cell(10, 4), Cell(10, 5), Cell(11, 0)],
      [Cell(12, 0), Cell(12, 1), Cell(12, 2), Cell(12, 3), Cell(12, 4), Cell(12, 5)]
    ];
    expect(store.state.wordsInWord.cells, expectedCells);

    // Slots | reminder: slotWidth = 36 | screenWidth *= 0.9 for margin
    store.dispatch(UpdateWordsInWordState(store.state.wordsInWord.copyWith(
      slots: Word.from("ABCDEFG", 0, false).chars,
    )));
    store.dispatch(recomputeSlotsIndexes);
    expect(store.state.wordsInWord.slotsDisplayIndexes, [
      [0, 1, 2, 3, 4],
      [5, 6],
    ]);
  });

  test("Compute cells bug on Matio 4:10", () {
    final text = "Fa hoy Jesosy taminy: Mandehana ianao, ry Satana: fa voasoratra hoe; "
        "Jehovah Andriamanitrao no hiankohofanao, ary Izy irery ihany no hotompoinao (Deo. 6. 13).";
    final words = BibleVerse.from(bookId: 1, book: "", chapter: 4, verse: 10, text: text).words;
    final cells = computeCells(words, 320);
    expect(cells.where((c) => c.length == 0).length, 0);
  });

  testWidgets("In game interractivity - Tap + propose", (WidgetTester tester) async {
    final verse = BibleVerse.from(bookId: 1, book: "Matio", chapter: 1, verse: 1, text: "Ny teny ny Azy");
    final initialState = AppState(
      editor: EditorState(),
      sfx: SfxMock(),
      game: GameState.emptyState(),
      theme: AppColorTheme(),
      route: Routes.wordsInWord,
      dba: DbAdapterMock.withDefaultValues(),
      assetBundle: AssetBundleMock.withDefaultValue(),
      explorer: ExplorerState(),
      config: ConfigState.initialState(),
      wordsInWord: WordsInWordState.emptyState(),
    );
    final store = Store<AppState>(mainReducer, middleware: [thunkMiddleware], initialState: initialState);
    // This is to simulate previous game session
    store.dispatch(UpdateWordsInWordState(store.state.wordsInWord.copyWith(
      proposition: Word.from("AA", 0, false).chars,
    )));
    store.dispatch(UpdateGameVerse(verse));
    store.dispatch(initializeWordsInWordState);
    store.dispatch(UpdateWordsInWordState(store.state.wordsInWord.copyWith(
      slots: Word.from("NYTENY", 0, false).chars,
      slotsBackup: Word.from("NYTENY", 0, false).chars,
      slotsDisplayIndexes: [
        [0, 1, 2, 3, 4, 5]
      ],
    )));
    // Greeting sound effect is played when game is initialized
    // => proposition is reset
    await tester.pumpWidget(BibleGame(store));
    expect(find.byKey(Key("wordsInWord")), findsOneWidget);
    expect(store.state.wordsInWord.slots, Word.from("NYTENY", 0, false).chars);
    expect(store.state.wordsInWord.slotsBackup, Word.from("NYTENY", 0, false).chars);
    expect(store.state.wordsInWord.wordsToFind.map((w) => w.value), ["Ny", "teny", "Azy"]);
    expect(store.state.wordsInWord.proposition, []);
    // Tap on slot 0(N) and 2(E) => Update proposition => Empty slots 0, 2
    // Propose => Wrong => trigger Failure animation => play wrong sfx
    await tester.tap(find.byKey(Key("slot_0")));
    await tester.tap(find.byKey(Key("slot_3")));
    await tester.pump(Duration(milliseconds: 10));
    expect(store.state.wordsInWord.proposition, [
      Char(value: "N", comparisonValue: "n"),
      Char(value: "E", comparisonValue: "e"),
    ]);
    expect(store.state.wordsInWord.slots, [
      null,
      ...Word.from("YT", 0, false).chars,
      null,
      ...Word.from("NY", 0, false).chars,
    ]);
    await tester.tap(find.byKey(Key("proposeBtn")));
    await tester.pump(Duration(milliseconds: 10));
    expect(store.state.wordsInWord.proposition, []);
    expect(listEquals(store.state.wordsInWord.slots, Word.from("NYTENY", 0, false).chars), true);
    expect(listEquals(store.state.wordsInWord.slotsBackup, Word.from("NYTENY", 0, false).chars), true);
    expect(store.state.wordsInWord.wordsToFind.length, 3);
    expect(store.state.wordsInWord.resolvedWords, []);
    expect(store.state.wordsInWord.propositionAnimation, PropositionAnimations.failure);

    // Tap on slot 4(N), 1(Y) => NY and Propose
    // => "Ny" is removed from words to find
    // => Success animation triggered
    // => Short Success sfx played
    await tester.tap(find.byKey(Key("slot_4")));
    await tester.pump(Duration(milliseconds: 10));
    await tester.tap(find.byKey(Key("slot_1")));
    await tester.pump(Duration(milliseconds: 10));
    await tester.tap(find.byKey(Key("proposeBtn")));
    await tester.pump(Duration(milliseconds: 10));
    expect(store.state.wordsInWord.proposition, []);
    expect(listEquals(store.state.wordsInWord.slots, Word.from("NYTENY", 0, false).chars), false);
    expect(listEquals(store.state.wordsInWord.slotsBackup, Word.from("NYTENY", 0, false).chars), false);
    expect(store.state.wordsInWord.wordsToFind.map((w) => w.value), ["teny", "Azy"]);
    expect(store.state.wordsInWord.resolvedWords, [Word.from("Ny", 0, false).copyWith(resolved: true)]);
    expect(store.state.game.verse.words.map((w) => w.value), ["Ny", " ", "teny", " ", "ny", " ", "Azy"]);
    expect(store.state.wordsInWord.propositionAnimation, PropositionAnimations.success);
    verify(store.state.sfx.playShortSuccess()).called(1);
    // Animation is removed automatically after 0.5s
    await tester.pump(Duration(seconds: 1));
    expect(store.state.wordsInWord.propositionAnimation, PropositionAnimations.none);
  });

  testWidgets("Click on bonuses", (WidgetTester tester) async {
    final verse = BibleVerse.from(book: "", bookId: 1, chapter: 1, verse: 1, text: "ABCDEFGHIJKLMNOPQRST");
    final state = AppState(
      sfx: SfxMock(),
      editor: EditorState(),
      theme: AppColorTheme(),
      game: GameState.emptyState().copyWith(
        verse: verse,
        inventory: InventoryState.emptyState().copyWith(
          money: 100,
          revealCharBonus1: 1,
          revealCharBonus2: 2,
          revealCharBonus5: 5,
          revealCharBonus10: 10,
          solveOneTurnBonus: 20,
        ),
      ),
      dba: DbAdapterMock.withDefaultValues(),
      assetBundle: AssetBundleMock.withDefaultValue(),
      explorer: ExplorerState(),
      config: ConfigState.initialState(),
      route: Routes.wordsInWord,
      wordsInWord: WordsInWordState(
        slots: verse.words[0].chars,
        slotsBackup: [],
        cells: [],
        wordsToFind: verse.words,
        proposition: [],
      ),
    );
    final store = Store<AppState>(
      mainReducer,
      initialState: state,
      middleware: [thunkMiddleware],
    );
    await tester.pumpWidget(BibleGame(store));

    // 1 - tap and tap again when there is no sold
    // play bonus sound effect
    await tester.tap(find.byKey(Key("revealCharBonusBtn_1")));
    await tester.pump();
    expect(store.state.game.verse.words[0].chars.where((c) => !c.resolved).length, 19);
    expect(store.state.game.inventory.revealCharBonus1, 0);
    await tester.tap(find.byKey(Key("revealCharBonusBtn_1")));
    await tester.pump();
    expect(store.state.game.verse.words[0].chars.where((c) => !c.resolved).length, 19);
    expect(store.state.game.inventory.revealCharBonus1, 0);
    verify(store.state.sfx.playBonus()).called(1);
    // 2
    await tester.pumpWidget(BibleGame(store));
    await tester.tap(find.byKey(Key("revealCharBonusBtn_2")));
    await tester.pump();
    expect(store.state.game.verse.words[0].chars.where((c) => !c.resolved).length, 17);
    expect(store.state.game.inventory.revealCharBonus2, 1);
    // 5
    await tester.pumpWidget(BibleGame(store));
    await tester.tap(find.byKey(Key("revealCharBonusBtn_5")));
    await tester.tap(find.byKey(Key("revealCharBonusBtn_5")));
    await tester.pump();
    expect(store.state.game.verse.words[0].chars.where((c) => !c.resolved).length, 7);
    expect(store.state.game.inventory.revealCharBonus5, 3);
    // 10 and only 6 is left and ignore the last tap as there is nothing to do
    await tester.pumpWidget(BibleGame(store));
    await tester.tap(find.byKey(Key("revealCharBonusBtn_10")));
    await tester.tap(find.byKey(Key("revealCharBonusBtn_10")));
    await tester.pump();
    expect(store.state.game.verse.words[0].chars.where((c) => !c.resolved).length, 1);
    expect(store.state.game.inventory.revealCharBonus10, 9);
    // Tap buttons when there is nothing to do
    await tester.tap(find.byKey(Key("revealCharBonusBtn_2")));
    await tester.tap(find.byKey(Key("revealCharBonusBtn_1")));
    await tester.tap(find.byKey(Key("revealCharBonusBtn_5")));
    await tester.pump();
    expect(store.state.game.verse.words[0].chars.where((c) => !c.resolved).length, 1);
    expect(store.state.game.inventory.revealCharBonus10, 9);
    expect(store.state.game.inventory.money, 100);

    // No balance
    store.dispatch(UpdateInventory(InventoryState.emptyState().copyWith(
      revealCharBonus1: 0,
      revealCharBonus2: 0,
      revealCharBonus5: 0,
      revealCharBonus10: 0,
    )));
    store.dispatch(UpdateGameVerse(verse));
    // Tap buttons when there is nothing to do
    await tester.pump();
    await tester.tap(find.byKey(Key("revealCharBonusBtn_1")));
    await tester.tap(find.byKey(Key("revealCharBonusBtn_2")));
    await tester.tap(find.byKey(Key("revealCharBonusBtn_5")));
    await tester.tap(find.byKey(Key("revealCharBonusBtn_10")));
    await tester.pump();
    expect(store.state.game.verse.words[0].chars.where((c) => !c.resolved).length, 20);
    expect(store.state.game.inventory.revealCharBonus1, 0);
    expect(store.state.game.inventory.revealCharBonus2, 0);
    expect(store.state.game.inventory.revealCharBonus5, 0);
    expect(store.state.game.inventory.revealCharBonus10, 0);
  });

  testWidgets("useBonus", (WidgetTester tester) async {
    final store = Store<AppState>(
      mainReducer,
      middleware: [thunkMiddleware],
      initialState: AppState(
        assetBundle: null,
        sfx: SfxMock(),
        editor: EditorState(),
        theme: AppColorTheme(),
        game: GameState.emptyState().copyWith(
          inventory: InventoryState.emptyState().copyWith(
            revealCharBonus1: 10,
            revealCharBonus2: 20,
            revealCharBonus5: 50,
            revealCharBonus10: 100,
          ),
        ),
        config: ConfigState(screenWidth: 100),
        dba: DbAdapterMock.withDefaultValues(),
        route: Routes.wordsInWord,
        explorer: null,
        wordsInWord: WordsInWordState.emptyState().copyWith(),
      ),
    );
    final verse = BibleVerse.from(text: "ABCDE EFGHI HIJKL MNOPQ");
    store.dispatch(UpdateGameVerse(verse));
    store.dispatch(initializeWordsInWordState);
    store.dispatch(UpdateWordsInWordState(store.state.wordsInWord.copyWith(
      wordsToFind: [
        verse.words[0].copyWith(bonus: RevealCharBonus(1, 0)),
        verse.words[2].copyWith(bonus: RevealCharBonus(2, 0)),
        verse.words[4].copyWith(bonus: RevealCharBonus(5, 0)),
      ],
    )));
    expect(countUnrevealedWord(store.state.game.verse.words), 20);
    // A B C D E: bonus = 1
    // This play bonus sfx
    store.dispatch(UpdateWordsInWordState(store.state.wordsInWord.copyWith(
      proposition: verse.words[0].chars,
    )));
    store.dispatch(proposeWordsInWord);
    expect(countUnrevealedWord(store.state.game.verse.words), 14);
    verify(store.state.sfx.playBonus()).called(1);
    // E F G H I: bonus = 3 (play bonus sfx again)
    store.dispatch(UpdateWordsInWordState(store.state.wordsInWord.copyWith(
      proposition: verse.words[2].chars,
    )));
    final prevUnrevealedCount = countUnrevealedWord([store.state.game.verse.words[2]]);
    store.dispatch(proposeWordsInWord);
    if (prevUnrevealedCount == 5) {
      expect(countUnrevealedWord(store.state.game.verse.words), 7);
    } else {
      expect(countUnrevealedWord(store.state.game.verse.words), 8);
    }
    verify(store.state.sfx.playBonus()).called(1);
  });
}

int countUnrevealedWord(List<Word> words) {
  final wordLengths =
      words.where((w) => !w.isSeparator && !w.resolved).map((w) => w.chars.where((c) => !c.resolved).length);
  return wordLengths.isEmpty ? 0 : wordLengths.reduce((a, b) => a + b);
}
