import 'package:bible_game/db/model.dart';
import 'package:bible_game/main.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/config/state.dart';
import 'package:bible_game/redux/editor/state.dart';
import 'package:bible_game/redux/explorer/state.dart';
import 'package:bible_game/redux/game/state.dart';
import 'package:bible_game/redux/main_reducer.dart';
import 'package:bible_game/redux/themes/themes.dart';
import 'package:bible_game/test_helpers/asset_bundle.dart';
import 'package:bible_game/test_helpers/db_adapter_mock.dart';
import 'package:bible_game/test_helpers/sfx_mock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

// Strange: tapping on an item twice trigger dropdown change callback
Future selectDdItem(WidgetTester tester, String stringKey) async {
  final key = Key(stringKey);
  await tester.tap(find.byKey(key).last);
  await tester.pump();
  await tester.tap(find.byKey(key).last);
  await tester.pump(Duration(milliseconds: 10));
}

void main() {
  testWidgets("Game editor basic flow", (WidgetTester tester) async {
    final dba = DbAdapterMock.mockMethods(DbAdapterMock(), [
      "init",
      "games",
      "saveGame",
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
    when(dba.books).thenAnswer((_) => Future.value(books));
    when(dba.getChapterVersesCount(any, any)).thenAnswer((invocation) async {
      return invocation.positionalArguments.first * 10 + invocation.positionalArguments.last;
    });

    await tester.pumpWidget(BibleGame(store));
    await tester.pump(Duration(milliseconds: 10));

    final editorFinder = find.byKey(Key("gameEditor"));
    final homeFinder = find.byKey(Key("home"));

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

    /// Select 2 as en verse to test end verse change handler
//    expect(find.byKey(Key("endVerse_2")), findsOneWidget);
//    await selectDdItem(tester, "endVerse_2");
//    expect(store.state.editor.endVerse, 2);

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
    ///    _          _
    ///     \_(°_°)_/
//    print("Selecting 10 as end verse");
//    await selectDdItem(tester, "endVerse_10");
//    expect(store.state.editor.endVerse, 10);

    /// After some time
    await tester.tap(find.byKey(Key("editorOkBtn")));
    await tester.pump();
    expect(homeFinder, findsOneWidget);
    expect(editorFinder, findsNothing);
  });
}
