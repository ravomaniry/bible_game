import 'package:bible_game/db/model.dart';
import 'package:bible_game/main.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/config/state.dart';
import 'package:bible_game/redux/explorer/state.dart';
import 'package:bible_game/redux/game/state.dart';
import 'package:bible_game/redux/main_reducer.dart';
import 'package:bible_game/redux/words_in_word/actions.dart';
import 'package:bible_game/redux/words_in_word/logics.dart';
import 'package:bible_game/test_helpers/asset_bundle.dart';
import 'package:bible_game/test_helpers/db_adapter_mock.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redux_thunk/redux_thunk.dart';

void main() {
  testWidgets("Open a game + next verse and save flow", (WidgetTester tester) async {
    final dba = DbAdapterMock();
    DbAdapterMock.mockMethods(dba, [
      "init",
      "saveGame",
      "games.saveAll",
      "getBooksCount",
      "getVersesCount",
      "getBooks",
      "getVerses",
      "verses.saveAll",
      "books.saveAll",
      "getBookById",
      "getBookVersesCount",
    ]);
    final store = Store<AppState>(
      mainReducer,
      middleware: [thunkMiddleware],
      initialState: AppState(
        game: GameState.emptyState(),
        dba: dba,
        assetBundle: AssetBundleMock.withDefaultValue(),
        config: ConfigState.initialState(),
        explorer: ExplorerState(),
      ),
    );

    final books = [BookModel(id: 1, name: "AAA", chapters: 10)];
    when(dba.books).thenAnswer((_) => Future.value(books));
    when(dba.games).thenAnswer(
      (_) => Future.value([
        GameModel(
          id: 1,
          startBook: 1,
          startChapter: 1,
          startVerse: 1,
          nextBook: 1,
          nextChapter: 1,
          nextVerse: 1,
          endBook: 1,
          endChapter: 1,
          endVerse: 10,
          money: 10,
          name: "Game1",
          bonuses: '{ "rcb_1": 1, "rcb_2": 2, "rcb_5": 5, "rcb_10": 10 }',
          versesCount: 10,
          resolvedVersesCount: 0,
        ),
        GameModel(
          id: 2,
          startBook: 1,
          startChapter: 2,
          startVerse: 1,
          nextBook: 1,
          nextChapter: 2,
          nextVerse: 1,
          endBook: 1,
          endChapter: 2,
          endVerse: 10,
          versesCount: 20,
          resolvedVersesCount: 0,
          name: "Game2",
          bonuses: '{ "rcb_1": 10, "rcb_2": 5, "rcb_5": 2, "rcb_10": 1 }',
          money: 20,
        ),
      ]),
    );

    when(dba.getSingleVerse(1, 1, 1)).thenAnswer((_) => Future.value(VerseModel(
          id: 1,
          book: 1,
          chapter: 1,
          verse: 1,
          text: "AOKA",
        )));

    await tester.pumpWidget(BibleGame(store));
    await tester.pump();

    final game1Button = find.byKey(Key("game_1"));
    final game2Button = find.byKey(Key("game_2"));
    final wordsInWord = find.byKey(Key("wordsInWord"));
    final solutionScreen = find.byKey(Key("solutionScreen"));
    final inventoryDialog = find.byKey(Key("inventoryDialog"));
    final inventoryOkBtn = find.byKey(Key("inventoryOkButton"));
    expect(game1Button, findsOneWidget);
    expect(game2Button, findsOneWidget);
    // select game 1
    await tester.tap(game1Button);
    await tester.pump(Duration(milliseconds: 10));
    // 1- game verse and game index is updated
    expect(store.state.game.activeId, 1);
    expect(store.state.game.verse.text, "AOKA");
    // 2- inventory should be updated
    expect(store.state.game.inventory.money, 10);
    expect(store.state.game.inventory.revealCharBonus1, 1);
    expect(store.state.game.inventory.revealCharBonus2, 2);
    expect(store.state.game.inventory.revealCharBonus5, 5);
    expect(store.state.game.inventory.revealCharBonus10, 10);
    // 3- words in word is initialized (or any other game if applicable)
    expect(store.state.wordsInWord.wordsToFind.map((w) => w.value), ["AOKA"]);

    // Before each game, the bonus shop should be open + when the dialog is closed, save the game
    expect(find.byKey(Key("inventoryDialog")), findsOneWidget);
    await tester.tap(find.byKey(Key("revealCharBonusBtn_1")));
    await tester.tap(find.byKey(Key("inventoryOkButton")));
    await tester.pump(Duration(milliseconds: 10));
    expect(store.state.game.list[0].inventory.revealCharBonus1, 2);
    expect(store.state.game.list[0].inventory.money, 5); // reminder price is 2 Ar.
    verify(dba.saveGame(any)).called(1);

    // ********** Complete a game ***********
    // => show solution screen
    store.dispatch(UpdateWordsInWordState(store.state.wordsInWord.copyWith(
      slots: Word.from("AOKA", 0, false).chars,
      proposition: Word.from("AOKA", 0, false).chars,
    )));
    store.dispatch(proposeWordsInWord);
    await tester.pump();
    expect(store.state.wordsInWord.wordsToFind, []);
    expect(store.state.game.isResolved, true);
    expect(store.state.game.inventory.money, 9);
    expect(solutionScreen, findsOneWidget);
    expect(wordsInWord, findsNothing);

    // => click on next
    when(dba.getSingleVerse(1, 1, 2)).thenAnswer(
      (_) => Future.value(VerseModel(
        id: 2,
        book: 1,
        chapter: 1,
        verse: 2,
        text: "ISIKA",
      )),
    );
    await tester.tap(find.byKey(Key("nextButton")));
    await tester.pump(Duration(milliseconds: 10));
    // Increment and save everything => load next verse => save the game in db
    final game = store.state.game.list[0];
    expect(game.resolvedVersesCount, 1);
    expect(game.model.money, 9);
    verify(dba.saveGame(any)).called(1);
    expect(game.nextVerse, 2);
    expect(store.state.game.verse.words[0].value, "ISIKA");

    // show the bonus screen and save game in db when closing the dialog
    expect(inventoryDialog, findsOneWidget);
    await tester.tap(inventoryOkBtn);
    await tester.pump();
    expect(inventoryDialog, findsNothing);
    expect(wordsInWord, findsOneWidget);
  });
}
