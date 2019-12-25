import 'package:bible_game/db/model.dart';
import 'package:bible_game/main.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/config/state.dart';
import 'package:bible_game/redux/editor/actions.dart';
import 'package:bible_game/redux/editor/state.dart';
import 'package:bible_game/redux/explorer/state.dart';
import 'package:bible_game/redux/game/state.dart';
import 'package:bible_game/redux/main_reducer.dart';
import 'package:bible_game/redux/themes/themes.dart';
import 'package:bible_game/test_helpers/asset_bundle.dart';
import 'package:bible_game/test_helpers/db_adapter_mock.dart';
import 'package:bible_game/test_helpers/sfx_mock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

// Strange: tapping on an item twice trigger dropdown change callback
Future selectDdItem(WidgetTester tester, String stringKey) async {
  final finder = find.byKey(Key(stringKey));
  await tester.tap(finder);
  await tester.pump();
  await tester.tap(finder.last);
  await tester.pump(Duration(seconds: 10));
}

void main() {
  testWidgets("Game editor basic flow", (WidgetTester tester) async {
    final dba = DbAdapterMock.mockMethods(DbAdapterMock(), [
      "init",
      "games",
      "games.saveAll",
      "getBooksCount",
      "getVersesCount",
      "getBooks",
      "getVerses",
      "getSingleVerse",
      "verses.saveAll",
      "books.saveAll",
      "getBookById",
    ]);
    final store = Store<AppState>(
      mainReducer,
      initialState: AppState(
        sfx: SfxMock(),
        editor: EditorState(),
        theme: AppColorTheme(),
        dba: dba,
        assetBundle: AssetBundleMock.withDefaultValue(),
        config: ConfigState.initialState(),
        explorer: ExplorerState(),
        game: GameState.emptyState(),
      ),
      middleware: [thunkMiddleware],
    );
    final List<BookModel> books = [
      BookModel(id: 1, name: "Matio", chapters: 1),
      BookModel(id: 2, name: "Marka", chapters: 2),
      BookModel(id: 3, name: "Lioka", chapters: 3),
    ];
    GameModel savedGame;

    when(dba.books).thenAnswer((_) => Future.value(books));
    when(dba.getChapterVersesCount(any, any)).thenAnswer((invocation) async {
      return invocation.positionalArguments.first * 10 + invocation.positionalArguments.last;
    });
    when(dba.getVersesNumBetween(
      startBook: anyNamed("startBook"),
      startChapter: anyNamed("startChapter"),
      startVerse: anyNamed("startVerse"),
      endBook: anyNamed("endBook"),
      endChapter: anyNamed("endChapter"),
      endVerse: anyNamed("endVerse"),
    )).thenAnswer((_) => Future.value(100));
    when(dba.saveGame(any)).thenAnswer((call) async {
      savedGame = call.positionalArguments.first;
      return 10;
    });

    await tester.pumpWidget(BibleGame(store));
    await tester.pump(Duration(milliseconds: 10));

    final editorFinder = find.byKey(Key("gameEditor"));
    final homeFinder = find.byKey(Key("home"));

    /// Initial side effect(s)
    verify(dba.games).called(1);

    /// Navigation => go to editor
    // Side effect: select book 1, load chapter 1 verses num
    await tester.tap(find.byKey(Key("goToEditor")));
    await tester.pump(Duration(milliseconds: 10));
    expect(store.state.editor.versesNumRefs.length, 1);
    expect(store.state.editor.versesNumRefs.first.toString(), "1:1 11");
    expect(store.state.editor.startBook, 1);
    expect(store.state.editor.startChapter, 1);
    expect(store.state.editor.startVerse, 1);
    expect(store.state.editor.endBook, 1);
    expect(store.state.editor.endChapter, 1);
    expect(store.state.editor.endVerse, 11);
    expect(editorFinder, findsOneWidget);
    expect(homeFinder, findsNothing);
    expect(find.byKey(Key("endBook_1")), findsOneWidget);

    /// Select start book
    // => update store
    // => load verses num
    // => auto populate end fields: select last chapter + last verse and ends
    // => restrict end books list (Book 2 and book 3 only)
    // => call select endBook internally if startBook > endBook
    await selectDdItem(tester, "startBook_2");
    expect(store.state.editor.startBook, 2);
    expect(store.state.editor.versesNumRefs.length, 3);
    expect(store.state.editor.versesNumRefs[1].toString(), "2:1 21");
    expect(store.state.editor.versesNumRefs[2].toString(), "2:2 22");
    expect(store.state.editor.startBook, 2);
    expect(store.state.editor.startChapter, 1);
    expect(store.state.editor.startVerse, 1);
    expect(store.state.editor.endBook, 2);
    expect(store.state.editor.endChapter, 2);
    expect(store.state.editor.endVerse, 22);
    expect(find.byKey(Key("endBook_1")), findsNothing);
    expect(find.byKey(Key("endBook_2")), findsOneWidget);

    /// Select start chapter
    // => update store
    // => load verses num
    // => auto populate fields
    await selectDdItem(tester, "startChapter_2");
    expect(store.state.editor.versesNumRefs.length, 3);
    expect(store.state.editor.startChapter, 2);
    expect(store.state.editor.startVerse, 1);
    expect(store.state.editor.endBook, 2);
    expect(store.state.editor.endChapter, 2);
    expect(store.state.editor.endVerse, 22);

    /// Select start verse
    // => update store
    // => Auto populate end verse
    // => restrict end verse list
    await selectDdItem(tester, "startVerse_4");
    expect(store.state.editor.startVerse, 4);
    expect(store.state.editor.endVerse, 22);
    expect(find.byKey(Key("endVerse_3")), findsNothing);
    expect(find.byKey(Key("endVerse_4")), findsWidgets);

    /// End book
    // => Update store (end book, last chapter + last verse)
    // ++ end book != startBook so all chapters is available
    await selectDdItem(tester, "endBook_3");
    expect(store.state.editor.versesNumRefs.length, 4);
    expect(store.state.editor.versesNumRefs.last.toString(), "3:3 33");
    expect(store.state.editor.endBook, 3);
    expect(store.state.editor.endChapter, 3);
    expect(store.state.editor.endVerse, 33);
    expect(find.byKey(Key("endChapter_1")), findsWidgets);

    /// End chapter
    // => Update store + last verse as endVerse
    await selectDdItem(tester, "endChapter_1");
    expect(store.state.editor.versesNumRefs.length, 5);
    expect(store.state.editor.versesNumRefs.last.toString(), "3:1 31");
    expect(store.state.editor.endChapter, 1);
    expect(store.state.editor.endVerse, 31);

    /// The onChanged callback is not fired on endVerse
    /// This part needs to be tested manually
    ///    _          _
    ///     \_(°_°)_/
    // await selectDdItem(tester, "endVerse_8");
    // expect(store.state.editor.endVerse, 8);

    /// After some time => close dialog => save game => sync games list with DB
    await tester.tap(find.byKey(Key("editorOkBtn")));
    await tester.pump();
    expect(homeFinder, findsOneWidget);
    expect(editorFinder, findsNothing);

    verify(dba.saveGame(any)).called(1);
    verify(dba.games).called(1);
    expect(savedGame.name, "Marka 2:4 - Lioka 1:31");
    expect(savedGame.startBook, 2);
    expect(savedGame.startChapter, 2);
    expect(savedGame.startVerse, 4);
    expect(savedGame.endBook, 3);
    expect(savedGame.endChapter, 1);
    expect(savedGame.endVerse, 31);
    expect(savedGame.nextBook, 2);
    expect(savedGame.nextChapter, 2);
    expect(savedGame.nextVerse, 4);
    expect(savedGame.versesCount, 100);
    expect(savedGame.resolvedVersesCount, 0);
    expect(savedGame.money, 0);
    expect(savedGame.bonuses, '{"rcb_1":10,"rcb_2":10,"rcb_5":5,"rcb_10":5}');
  });

  testWidgets("Auto populate end chapter and end verse", (WidgetTester tester) async {
    final dba = DbAdapterMock.mockMethods(DbAdapterMock(), [
      "init",
      "games",
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
      "getVersesNumBetween",
    ]);
    final store = Store<AppState>(
      mainReducer,
      initialState: AppState(
        theme: AppColorTheme(),
        explorer: ExplorerState(),
        config: ConfigState.initialState(),
        assetBundle: AssetBundleMock.withDefaultValue(),
        dba: dba,
        sfx: SfxMock(),
        editor: EditorState(),
        game: GameState.emptyState(),
      ),
      middleware: [thunkMiddleware],
    );

    when(dba.getChapterVersesCount(any, any)).thenAnswer((_) => Future.value(10));

    await tester.pumpWidget(BibleGame(store));
    await tester.pump(Duration(milliseconds: 10));
    await tester.tap(find.byKey(Key("goToEditor")));
    await tester.pump(Duration(milliseconds: 10));

    // Auto-populate end chapter and end verse
    await selectDdItem(tester, "startChapter_2");
    expect(store.state.editor.startChapter, 2);
    expect(store.state.editor.endChapter, 2);
    expect(store.state.editor.endVerse, 10);
    // Auto-populate end verse
    store.dispatch(endVerseChangeHandler(5));
    expect(store.state.editor.endVerse, 5);
    await tester.pump();
    await selectDdItem(tester, "startVerse_6");
    expect(store.state.editor.startChapter, 2);
    expect(store.state.editor.startVerse, 6);
    expect(store.state.editor.endVerse, 10);
  });
}
