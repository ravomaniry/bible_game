import 'file:///media/data/sc/perso/bible_game/test/helpers/db_adapter_mock.dart';
import 'package:bible_game/db/model.dart';
import 'package:bible_game/main.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/main_reducer.dart';
import 'package:bible_game/statics.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redux_thunk/redux_thunk.dart';

import 'helpers/asset_bundle.dart';

void main() {
  testWidgets("Db initialization failure", (WidgetTester tester) async {
    final dba = DbAdapterMock();
    final store = Store<AppState>(
      mainReducer,
      middleware: [thunkMiddleware],
      initialState: AppState(
        dba: dba,
        assetBundle: AssetBundleMock.withDefaultValue(),
      ),
    );
    when(dba.init()).thenAnswer((_) => Future.value(false));
    await tester.pumpWidget(BibleGame(store));
    expect(store.state.error, Errors.dbNotReady);
  });

  testWidgets("Db initialization success", (WidgetTester tester) async {
    final dba = DbAdapterMock();
    final store = Store<AppState>(
      mainReducer,
      middleware: [thunkMiddleware],
      initialState: AppState(
        dba: dba,
        assetBundle: AssetBundleMock.withDefaultValue(),
      ),
    );
    when(dba.init()).thenAnswer((_) => Future.value(true));
    when(dba.getBooksCount()).thenAnswer((_) => Future.value(0));
    when(dba.getVersesCount()).thenAnswer((_) => Future.value(0));
    await tester.pumpWidget(BibleGame(store));
    expect(store.state.error, null);
    verify(dba.books.saveAll(any)).called(1);
    verify(dba.verses.saveAll(any)).called(1);
  });
}
