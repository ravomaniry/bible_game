import 'package:bible_game/main.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/config/state.dart';
import 'package:bible_game/redux/explorer/state.dart';
import 'package:bible_game/redux/inventory/state.dart';
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
    final dba = DbAdapterMock();
    DbAdapterMock.mockMethods(dba, ["verses.saveAll", "books.saveAll"]);
    final store = Store<AppState>(
      mainReducer,
      middleware: [thunkMiddleware],
      initialState: AppState(
        dba: dba,
        explorer: ExplorerState(),
        assetBundle: AssetBundleMock.withDefaultValue(),
        config: ConfigState.initialState(),
        inventory: InventoryState.emptyState(),
      ),
    );
    when(dba.init()).thenAnswer((_) => Future.value(false));
    await tester.pumpWidget(BibleGame(store));
    expect(store.state.error, Errors.dbNotReady);
  });

  testWidgets("Db initialization success", (WidgetTester tester) async {
    final dba = DbAdapterMock();
    DbAdapterMock.mockMethods(dba, ["verses.saveAll", "books.saveAll"]);
    final store = Store<AppState>(
      mainReducer,
      middleware: [thunkMiddleware],
      initialState: AppState(
        dba: dba,
        explorer: ExplorerState(),
        assetBundle: AssetBundleMock.withDefaultValue(),
        config: ConfigState.initialState(),
        inventory: InventoryState.emptyState(),
      ),
    );
    when(dba.init()).thenAnswer((_) => Future.value(true));
    when(dba.getBooksCount()).thenAnswer((_) => Future.value(0));
    when(dba.getVersesCount()).thenAnswer((_) => Future.value(0));
    expect(store.state.dbIsReady, false);

    await tester.pumpWidget(BibleGame(store));
    expect(store.state.error, null);
    verify(dba.books.saveAll(any)).called(1);
    verify(dba.verses.saveAll(any)).called(1);
    expect(store.state.dbIsReady, true);
  });
}
