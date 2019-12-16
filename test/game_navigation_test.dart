import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:bible_game/db/model.dart';
import 'package:bible_game/main.dart';
import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/config/state.dart';
import 'package:bible_game/redux/explorer/state.dart';
import 'package:bible_game/redux/game/actions.dart';
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
    final dba = DbAdapterMock.mockMethods(DbAdapterMock(), [
      "init",
      "saveGame",
      "games.saveAll",
      "getBooksCount",
      "getVersesCount",
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

    final books = [1, 2, 3, 4, 5, 6].map((id) => BookModel(id: id, name: "$id", chapters: 10)).toList();
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
          money: 15,
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

    final verse0 = VerseModel(
      id: 1,
      book: 1,
      chapter: 1,
      verse: 1,
      text: "AOKA",
    );
    final verse1 = VerseModel(
      id: 2,
      book: 1,
      chapter: 1,
      verse: 2,
      text: "ISIKA",
    );
    when(dba.getSingleVerse(1, 1, 1)).thenAnswer((_) => Future.value(verse0));
    when(dba.books).thenAnswer((_) => Future.value(books));
    when(dba.getSingleVerse(1, 1, 2)).thenAnswer((_) => Future.value(verse1));
    when(dba.getSingleVerse(1, 2, 1)).thenAnswer((_) => Future.value(verse0));

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
    expect(store.state.game.inventory.money, 15);
    expect(store.state.game.inventory.revealCharBonus1, 1);
    expect(store.state.game.inventory.revealCharBonus2, 2);
    expect(store.state.game.inventory.revealCharBonus5, 5);
    expect(store.state.game.inventory.revealCharBonus10, 10);
    // 3- words in word is initialized (or any other game if applicable)
    expect(store.state.wordsInWord.wordsToFind.map((w) => w.value), ["AOKA"]);

    // Before each game, the bonus shop should be open + when the dialog is closed, save the game
    // Buy a bonus 1: 10Ar
    expect(find.byKey(Key("inventoryDialog")), findsOneWidget);
    await tester.tap(find.byKey(Key("revealCharBonusBtn_1")));
    await tester.tap(find.byKey(Key("inventoryOkButton")));
    await tester.pump(Duration(milliseconds: 10));
    expect(store.state.game.list[0].inventory.revealCharBonus1, 2);
    expect(store.state.game.list[0].inventory.money, 5);
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

    // Navigate to the other game
    BackButtonInterceptor.popRoute();
    await tester.pump();
    await tester.tap(find.byKey(Key("dialogYesBtn")));
    await tester.pump();

    expect(find.byKey(Key("home")), findsOneWidget);
    await tester.tap(game2Button);
    await tester.pump(Duration(milliseconds: 10));
    verify(dba.getSingleVerse(1, 2, 1)).called(1);
    expect(store.state.game.inventory.money, 20);
  });

  testWidgets("Load next verse", (WidgetTester tester) async {
    final state = AppState(
      game: GameState.emptyState(),
      assetBundle: AssetBundleMock.withDefaultValue(),
      explorer: ExplorerState(),
      config: ConfigState.initialState(),
      dba: DbAdapterMock.mockMethods(DbAdapterMock(), [
        "init",
        "saveGame",
        "games.saveAll",
        "getBooksCount",
        "getVersesCount",
        "getVerses",
        "verses.saveAll",
        "books.saveAll",
        "getBookVersesCount",
      ]),
    );
    final store = Store<AppState>(
      mainReducer,
      initialState: state,
      middleware: [thunkMiddleware],
    );
    final games = [
      GameModel(
        id: 1,
        name: "Filazantsara",
        startBook: 1,
        startChapter: 1,
        startVerse: 1,
        endBook: 2,
        endChapter: 1,
        endVerse: 1,
        nextBook: 1,
        nextVerse: 1,
        nextChapter: 1,
        versesCount: 10,
        resolvedVersesCount: 0,
        money: 0,
        bonuses: "{}",
      )
    ];
    final books = [
      BookModel(id: 1, name: "A", chapters: 2),
      BookModel(id: 2, name: "B", chapters: 2),
    ];
    final book1 = BookModel(id: 1, name: "Genesisy", chapters: 10);
    final verseA11 = VerseModel(id: 1, book: 1, chapter: 1, verse: 1, text: "TestA");
    final verseA12 = VerseModel(id: 2, book: 1, chapter: 1, verse: 2, text: "TestB");
    final verseA21 = VerseModel(id: 3, book: 1, chapter: 2, verse: 1, text: "TestC.");
    final verseB11 = VerseModel(id: 4, book: 2, chapter: 1, verse: 1, text: "TestD.");
    when(state.dba.games).thenAnswer((_) => Future.value(games));
    when(state.dba.books).thenAnswer((_) => Future.value(books));
    when(state.dba.getBookById(1)).thenAnswer((_) => Future.value(book1));
    // 111 -> 112 -> 121 -> 211
    when(state.dba.getSingleVerse(1, 1, 1)).thenAnswer((_) => Future.value(verseA11));
    when(state.dba.getSingleVerse(1, 1, 2)).thenAnswer((_) => Future.value(verseA12));
    when(state.dba.getSingleVerse(1, 1, 3)).thenAnswer((_) => Future.value(null));
    when(state.dba.getSingleVerse(1, 2, 1)).thenAnswer((_) => Future.value(verseA21));
    when(state.dba.getSingleVerse(1, 2, 2)).thenAnswer((_) => Future.value(null));
    when(state.dba.getSingleVerse(2, 1, 1)).thenAnswer((_) => Future.value(verseB11));

    final nextBtn = find.byKey(Key("nextButton"));
    final closeInventoryBtn = find.byKey(Key("inventoryOkButton"));

    await tester.pumpWidget(BibleGame(store));
    await tester.pump(Duration(milliseconds: 10));

    // open game 1 and close inventory
    await tester.tap(find.byKey(Key("game_1")));
    await tester.pump(Duration(milliseconds: 10));
    await tester.tap(closeInventoryBtn);
    await tester.pump(Duration(milliseconds: 10));
    expect(store.state.game.verse, BibleVerse.fromModel(verseA11, "A"));
    verify(store.state.dba.getSingleVerse(1, 1, 1)).called(1);
    // resolve game: call getBookById => load verse A12
    store.dispatch(UpdateGameResolvedState(true));
    await tester.pump(Duration(milliseconds: 10));
    await tester.tap(nextBtn);
    await tester.pump(Duration(milliseconds: 10));
    expect(store.state.game.verse, BibleVerse.fromModel(verseA12, "A"));
    expect(store.state.game.list[0].resolvedVersesCount, 1);

    await tester.tap(closeInventoryBtn);
    await tester.pump(Duration(milliseconds: 10));
    // Now should go to verse A2:1
    store.dispatch(UpdateGameResolvedState(true));
    await tester.pump();
    await tester.tap(nextBtn);
    await tester.pump(Duration(milliseconds: 10));
    expect(store.state.game.verse, BibleVerse.fromModel(verseA21, "A"));
    expect(store.state.game.list[0].resolvedVersesCount, 2);

    await tester.tap(closeInventoryBtn);
    await tester.pump(Duration(milliseconds: 10));
    // Now should go to verse 211 (this is the last verse)
    store.dispatch(UpdateGameResolvedState(true));
    await tester.pump();
    await tester.tap(nextBtn);
    await tester.pump(Duration(milliseconds: 10));
    expect(store.state.game.verse, BibleVerse.fromModel(verseB11, "B"));
    expect(store.state.game.list[0].resolvedVersesCount, 3);

    await tester.tap(closeInventoryBtn);
    await tester.pump(Duration(milliseconds: 10));
    expect(closeInventoryBtn, findsNothing);
    // Resolving the game now open the solution dialog + display congratulation message
    store.dispatch(UpdateGameResolvedState(true));
    await tester.pump(Duration(milliseconds: 100));
    await tester.tap(nextBtn);
    await tester.pump(Duration(milliseconds: 100));
    expect(nextBtn, findsNothing);
    expect(store.state.game.activeGameIsCompleted, true);
    expect(closeInventoryBtn, findsNothing);
    expect(find.byKey(Key("congratulations")), findsOneWidget);
    expect(store.state.game.verse, BibleVerse.fromModel(verseB11, "B"));
    expect(store.state.game.list[0].resolvedVersesCount, 4);
    // Closing congratulation message redirect to home
    await tester.tap(find.byKey(Key("congratulationsOkBtn")));
    await tester.pump();
    expect(find.byKey(Key("home")), findsOneWidget);

    await tester.tap(find.byKey(Key("game_1")));
    await tester.pump(Duration(milliseconds: 10));
    expect(store.state.game.activeGameIsCompleted, false);
  });
}
