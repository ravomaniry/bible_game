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
  testWidgets("Game editor test", (WidgetTester tester) async {
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
    ];
    when(dba.books).thenAnswer((_) => Future.value(books));
    when(dba.getChapterVersesCount(any, any)).thenAnswer((invocation) async {
      if (listEquals(invocation.positionalArguments, [1, 1])) {
        return 10;
      } else if (listEquals(invocation.positionalArguments, [2, 1])) {
        return 20;
      } else if (listEquals(invocation.positionalArguments, [2, 2])) {
        return 22;
      }
      return 1;
    });

    await tester.pumpWidget(BibleGame(store));
    await tester.pump(Duration(milliseconds: 10));

    final editorFinder = find.byKey(Key("gameEditor"));
    final homeFinder = find.byKey(Key("home"));

    // Navigation => go to editor
    // Side effect: select book 1, load chapter 1 verses num
    await tester.tap(find.byKey(Key("goToEditor")));
    await tester.pump();
    expect(store.state.editor.versesNumRefs.length, 1);
    expect(store.state.editor.versesNumRefs[0].toString(), "1:1 10");
    expect(store.state.editor.startBook, 1);
    expect(store.state.editor.startChapter, 1);
    expect(store.state.editor.startVerse, 1);
    expect(store.state.editor.endBook, 1);
    expect(store.state.editor.endChapter, 1);
    expect(store.state.editor.endVerse, 10);
    expect(editorFinder, findsOneWidget);
    expect(homeFinder, findsNothing);

    // Select start book => update store => load verses num => auto populate end fields
    await selectDdItem(tester, "startBook_2");
    expect(store.state.editor.startBook, 2);
    expect(store.state.editor.versesNumRefs.length, 2);
    expect(store.state.editor.versesNumRefs[1].toString(), "2:1 20");
    expect(store.state.editor.startBook, 2);
    expect(store.state.editor.startChapter, 1);
    expect(store.state.editor.startVerse, 1);
    expect(store.state.editor.endBook, 2);
    expect(store.state.editor.endChapter, 1);
    expect(store.state.editor.endVerse, 20);
    // Select chapter
    // => update store => load verses num => auto populate fields
    await selectDdItem(tester, "startChapter_2");
    expect(store.state.editor.versesNumRefs.length, 3);
    expect(store.state.editor.versesNumRefs[2].toString(), "2:2 22");
    expect(store.state.editor.startBook, 2);
    expect(store.state.editor.startChapter, 2);
    expect(store.state.editor.startVerse, 1);
    expect(store.state.editor.endBook, 2);
    expect(store.state.editor.endChapter, 2);
    expect(store.state.editor.endVerse, 22);
    // Select start verse => only update the store for this case
    await selectDdItem(tester, "startVerse_10");
    expect(store.state.editor.startVerse, 10);

    // After some time
    await tester.tap(find.byKey(Key("editorOkBtn")));
    await tester.pump();
    expect(homeFinder, findsOneWidget);
    expect(editorFinder, findsNothing);
  });
}
