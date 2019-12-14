import 'package:bible_game/db/model.dart';
import 'package:bible_game/main.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/config/state.dart';
import 'package:bible_game/redux/explorer/state.dart';
import 'package:bible_game/redux/game/init.dart';
import 'package:bible_game/redux/game/state.dart';
import 'package:bible_game/redux/main_reducer.dart';
import 'package:bible_game/statics/texts.dart';
import 'package:bible_game/test_helpers/asset_bundle.dart';
import 'package:bible_game/test_helpers/db_adapter_mock.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redux_thunk/redux_thunk.dart';

void main() {
  testWidgets("Db initialization failure", (WidgetTester tester) async {
    final dba = DbAdapterMock.mockMethods(DbAdapterMock(), ["verses.saveAll", "books.saveAll"]);
    final store = Store<AppState>(
      mainReducer,
      middleware: [thunkMiddleware],
      initialState: AppState(
        dba: dba,
        game: GameState.emptyState(),
        explorer: ExplorerState(),
        assetBundle: AssetBundleMock.withDefaultValue(),
        config: ConfigState.initialState(),
      ),
    );
    when(dba.init()).thenAnswer((_) => Future.value(false));
    await tester.pumpWidget(BibleGame(store));
    expect(store.state.error, Errors.dbNotReady);
  });

  testWidgets("Db initialization success", (WidgetTester tester) async {
    List<BookModel> booksListMock = [];
    defaultGames.forEach((game) {
      if (booksListMock.where((b) => b.id == game.startBook).isEmpty) {
        booksListMock.add(BookModel(id: game.startBook, name: "Book ${game.startBook}"));
      }
      if (booksListMock.where((b) => b.id == game.endBook).isEmpty) {
        booksListMock.add(BookModel(id: game.endBook, name: "Book ${game.endBook}"));
      }
    });

    final dba = DbAdapterMock();
    DbAdapterMock.mockMethods(dba, ["verses.saveAll", "books.saveAll", "games.saveAll"]);
    final store = Store<AppState>(
      mainReducer,
      middleware: [thunkMiddleware],
      initialState: AppState(
        dba: dba,
        game: GameState.emptyState(),
        explorer: ExplorerState(),
        assetBundle: AssetBundleMock.withDefaultValue(),
        config: ConfigState.initialState(),
      ),
    );
    when(dba.init()).thenAnswer((_) => Future.value(true));
    when(dba.booksCount).thenAnswer((_) => Future.value(0));
    when(dba.versesCount).thenAnswer((_) => Future.value(0));
    when(dba.games).thenAnswer((_) => Future.value([]));
    when(dba.books).thenAnswer((_) => Future.value(booksListMock));

    expect(store.state.dbIsReady, false);

    await tester.pumpWidget(BibleGame(store));
    await tester.pump(Duration(milliseconds: 10));
    // The books should be saved when db is initialized
    expect(store.state.error, null);
    verify(dba.bookModel.saveAll(any)).called(1);
    verify(dba.verseModel.saveAll(any)).called(1);
    verify(dba.gameModel.saveAll(any)).called(1);
    expect(store.state.dbIsReady, true);
    expect(store.state.game.list.length, defaultGames.length);
  });

  testWidgets("Initial data loading", (WidgetTester tester) async {
    final store = Store<AppState>(
      mainReducer,
      middleware: [thunkMiddleware],
      initialState: AppState(
        dba: DbAdapterMock.withDefaultValues(),
        game: GameState.emptyState(),
        explorer: ExplorerState(),
        assetBundle: AssetBundleMock.withDefaultValue(),
        config: ConfigState.initialState(),
      ),
    );

    expect(store.state.dbIsReady, false);
    await tester.pumpWidget(BibleGame(store));
    await tester.pump(Duration(milliseconds: 10));
    expect(store.state.dbIsReady, true);
    expect(store.state.game.list.length, 1);
    expect(store.state.game.books.length, 2);
    expect(store.state.game.list[0].startBookName, "Matio");
    expect(store.state.game.list[0].endBookName, "Matio");
  });
}
