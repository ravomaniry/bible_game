import 'package:bible_game/db/model.dart';
import 'package:bible_game/main.dart';
import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/config/state.dart';
import 'package:bible_game/redux/editor/state.dart';
import 'package:bible_game/redux/explorer/state.dart';
import 'package:bible_game/redux/game/state.dart';
import 'package:bible_game/redux/inventory/actions.dart';
import 'package:bible_game/redux/inventory/state.dart';
import 'package:bible_game/redux/main_reducer.dart';
import 'package:bible_game/redux/router/routes.dart';
import 'package:bible_game/redux/themes/themes.dart';
import 'package:bible_game/redux/words_in_word/actions.dart';
import 'package:bible_game/redux/words_in_word/logics.dart';
import 'package:bible_game/redux/words_in_word/state.dart';
import 'package:bible_game/test_helpers/asset_bundle.dart';
import 'package:bible_game/test_helpers/db_adapter_mock.dart';
import 'package:bible_game/test_helpers/sfx_mock.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

void main() {
  testWidgets("Invenrory - Basic flow", (WidgetTester tester) async {
    final dba = DbAdapterMock.mockMethods(DbAdapterMock(), [
      "init",
      "saveGame",
      "games.saveAll",
      "books",
      "getBooksCount",
      "getVersesCount",
      "getBooks",
      "getVerses",
      "getSingleVerse",
      "verses.saveAll",
      "books.saveAll",
      "getBookById",
      "getBookVersesCount",
    ]);
    final store = Store<AppState>(
      mainReducer,
      middleware: [thunkMiddleware],
      initialState: AppState(
        sfx: SfxMock(),
        editor: EditorState(),
        theme: AppColorTheme(),
        game: GameState.emptyState().copyWith(
          inventory: InventoryState.emptyState(),
        ),
        assetBundle: AssetBundleMock.withDefaultValue(),
        dba: dba,
        config: ConfigState.initialState(),
        explorer: ExplorerState(),
      ),
    );
    final game = GameModel(
      id: 1,
      name: "A",
      money: 300,
      bonuses: "{}",
      resolvedVersesCount: 0,
      versesCount: 10,
      nextVerse: 1,
      nextBook: 1,
      nextChapter: 1,
      endVerse: 10,
      endChapter: 10,
      endBook: 1,
      startBook: 1,
      startVerse: 1,
      startChapter: 1,
    );
    when(dba.games).thenAnswer((_) => Future.value([game]));

    await tester.pumpWidget(BibleGame(store));
    await tester.pump(Duration(milliseconds: 100));
    final inventoryFinder = find.byKey(Key("inventoryDialog"));

    // Select the first game and to the shopping there
    expect(inventoryFinder, findsNothing);
    await tester.tap(find.byKey(Key("game_1")));
    await tester.pump();
    expect(inventoryFinder, findsOneWidget);
    // buy bonuses (play sfx)
    await tester.tap(find.byKey(Key("revealCharBonusBtn_1")));
    await tester.tap(find.byKey(Key("revealCharBonusBtn_1")));
    await tester.pump(Duration(milliseconds: 200));
    expect(store.state.game.inventory.money, 280);
    expect(store.state.game.inventory.revealCharBonus1, 2);
    verify(store.state.sfx.playBonus()).called(2);
    // 1 * 2 + 2 * 5 + 4 * 10
    await tester.tap(find.byKey(Key("revealCharBonusBtn_2")));
    await tester.tap(find.byKey(Key("revealCharBonusBtn_5")));
    await tester.tap(find.byKey(Key("revealCharBonusBtn_5")));
    await tester.tap(find.byKey(Key("revealCharBonusBtn_5")));
    await tester.tap(find.byKey(Key("revealCharBonusBtn_10")));
    await tester.tap(find.byKey(Key("revealCharBonusBtn_10")));
    await tester.tap(find.byKey(Key("revealCharBonusBtn_10")));
    await tester.tap(find.byKey(Key("revealCharBonusBtn_10")));
    expect(store.state.game.inventory.money, 85);
    expect(store.state.game.inventory.revealCharBonus1, 2);
    expect(store.state.game.inventory.revealCharBonus2, 1);
    expect(store.state.game.inventory.revealCharBonus5, 3);
    expect(store.state.game.inventory.revealCharBonus10, 4);
    verify(store.state.sfx.playBonus()).called(8);

    // Exceed money (only 2 is accepted)
    for (var i = 0; i < 10; i++) {
      await tester.tap(find.byKey(Key("revealCharBonusBtn_10")));
    }
    expect(store.state.game.inventory.money, 25);
    expect(store.state.game.inventory.revealCharBonus10, 6);
    verify(store.state.sfx.playBonus()).called(2);

    // close the dialog
    await tester.tap(find.byKey(Key("inventoryOkButton")));
    await tester.pump();
    expect(inventoryFinder, findsNothing);
  });

  test("Score and combo - words in word mode", () {
    BibleVerse verse = BibleVerse.from(text: "AB AB CDEF GHIJK LMNO PQRSTUVX Y");
    verse = verse.copyWithWord(
      4,
      verse.words[4].copyWithChar(0, verse.words[4].chars[0].copyWith(resolved: true)),
    );
    final initialState = AppState(
      sfx: SfxMock(),
      editor: EditorState(),
      theme: AppColorTheme(),
      route: Routes.wordsInWord,
      game: GameState.emptyState().copyWith(
        verse: verse,
        inventory: InventoryState.emptyState().copyWith(money: 0),
      ),
      dba: DbAdapterMock.withDefaultValues(),
      assetBundle: AssetBundleMock.withDefaultValue(),
      explorer: ExplorerState(),
      config: ConfigState.initialState(),
      wordsInWord: WordsInWordState.emptyState().copyWith(
        wordsToFind: verse.words.sublist(1).where((w) => !w.isSeparator).toList(),
      ),
    );
    final store = Store<AppState>(mainReducer, middleware: [thunkMiddleware], initialState: initialState);
    // Resolving AB should increment score by 4
    store.dispatch(UpdateWordsInWordState(store.state.wordsInWord.copyWith(
      proposition: Word.from("AB", 0, false).chars,
    )));
    store.dispatch(proposeWordsInWord);
    expect(store.state.game.inventory.money, 4);
    expect(store.state.game.inventory.combo, 1);

    // Resolving "C D E F" should increment money by 3 as C is already resolved in advance
    // Resolving AB should increment score by 4
    store.dispatch(UpdateWordsInWordState(store.state.wordsInWord.copyWith(
      proposition: Word.from("CDEF", 0, false).chars,
    )));
    store.dispatch(proposeWordsInWord);
    expect(store.state.game.inventory.money, 7);
    expect(store.state.game.inventory.combo, 1);

    // Resolving G H I J K should increment combo by 0.5
    store.dispatch(UpdateWordsInWordState(store.state.wordsInWord.copyWith(
      proposition: Word.from("GHIJK", 0, false).chars,
    )));
    store.dispatch(proposeWordsInWord);
    expect(store.state.game.inventory.money, 12);
    expect(store.state.game.inventory.combo, 1.5);

    // Resolving L M N O should increment combo by 0.4 and increment money by 6
    store.dispatch(UpdateWordsInWordState(store.state.wordsInWord.copyWith(
      proposition: Word.from("LMNO", 0, false).chars,
    )));
    store.dispatch(proposeWordsInWord);
    expect(store.state.game.inventory.money, 18);
    expect(store.state.game.inventory.combo, 1.9);

    // Resolving 8 chars when combo is invalidated should increment combo by 0.8
    store.dispatch(InvalidateCombo());
    store.dispatch(UpdateWordsInWordState(store.state.wordsInWord.copyWith(
      proposition: Word.from("PQRSTUVX", 0, false).chars,
    )));
    store.dispatch(proposeWordsInWord);
    expect(store.state.game.inventory.money, 26);
    expect(store.state.game.inventory.combo, 1.8);

    // Last word invalidate combo
    store.dispatch(UpdateWordsInWordState(store.state.wordsInWord.copyWith(
      proposition: Word.from("Y", 0, false).chars,
    )));
    store.dispatch(proposeWordsInWord);
    expect(store.state.game.inventory.money, 28);
    expect(store.state.game.inventory.combo, 1);
  });
}
