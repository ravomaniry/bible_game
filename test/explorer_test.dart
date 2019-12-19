import 'package:bible_game/main.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/config/state.dart';
import 'package:bible_game/redux/explorer/state.dart';
import 'package:bible_game/redux/game/state.dart';
import 'package:bible_game/redux/main_reducer.dart';
import 'package:bible_game/redux/router/routes.dart';
import 'package:bible_game/redux/themes/themes.dart';
import 'package:bible_game/test_helpers/asset_bundle.dart';
import 'package:bible_game/test_helpers/db_adapter_mock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

void main() {
  testWidgets("Explorer widget test", (WidgetTester tester) async {
    final state = AppState(
      route: Routes.home,
      theme: AppColorTheme(),
      game: GameState.emptyState(),
      assetBundle: AssetBundleMock.withDefaultValue(),
      dba: DbAdapterMock.withDefaultValues(),
      explorer: ExplorerState(),
      config: ConfigState.initialState(),
    );
    final store = Store<AppState>(
      mainReducer,
      initialState: state,
      middleware: [thunkMiddleware],
    );
    final loaderFinder = find.byKey(Key("loader"));
    final explorerFinder = find.byKey(Key("explorer"));
    final explorerBtn = find.byKey(Key("goToExplorer"));
    final booksList = find.byKey(Key("booksList"));
    final verseDetails = find.byKey(Key("verseDetailsBackBtn"));

    await tester.pumpWidget(BibleGame(store));
    expect(loaderFinder, findsOneWidget);

    await tester.pump(Duration(seconds: 1));
    await tester.tap(explorerBtn);
    await tester.pump();
    expect(explorerFinder, findsOneWidget);
    expect(store.state.dbIsReady, true);
    expect(store.state.game.books.length, 2);
    expect(booksList, findsOneWidget);
    expect(verseDetails, findsNothing);

    await tester.tap(find.byKey(Key("1")));
    await tester.pump(Duration(seconds: 1));
    expect(store.state.explorer.activeBook.id, 1);
    expect(store.state.explorer.verses.length, 1);
    expect(booksList, findsNothing);
    expect(verseDetails, findsOneWidget);

    await tester.tap(find.byKey(Key("verseDetailsBackBtn")));
    await tester.pump();
    expect(state.explorer.activeBook, null);
    expect(booksList, findsOneWidget);
    expect(verseDetails, findsNothing);
  });
}
