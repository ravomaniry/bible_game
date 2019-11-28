import 'package:bible_game/db/model.dart';
import 'package:bible_game/main.dart';
import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/explorer/state.dart';
import 'package:bible_game/redux/main_reducer.dart';
import 'package:bible_game/test_helpers/asset_bundle.dart';
import 'package:bible_game/test_helpers/db_adapter_mock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

void main() {
  testWidgets("Words in word test", (WidgetTester tester) async {
    final state = AppState(
      assetBundle: AssetBundleMock.withDefaultValue(),
      dba: DbAdapterMock.withDefaultValues(),
      explorer: ExplorerState(),
    );
    final store = Store<AppState>(
      mainReducer,
      initialState: state,
      middleware: [thunkMiddleware],
    );
    await tester.pumpWidget(BibleGame(store));
    await tester.pump(Duration(milliseconds: 10)); // let the event loop tick to resolve futures
    await tester.tap(find.byKey(Key("goToWordsInWordBtn")));
    await tester.pump();
    await tester.pump(Duration(milliseconds: 10));
    expect(store.state.error == null, true);
    expect(store.state.wordsInWord.verse, BibleVerse.fromModel(await state.dba.getSingleVerse(1, 2, 3), "Genesisy"));
    verify(store.state.dba.getSingleVerse(1, 1, 2)).called(1);
  });
}
