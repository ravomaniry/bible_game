import 'package:bible_game/main.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/config/state.dart';
import 'package:bible_game/redux/explorer/state.dart';
import 'package:bible_game/redux/game/state.dart';
import 'package:bible_game/redux/main_reducer.dart';
import 'package:bible_game/test_helpers/asset_bundle.dart';
import 'package:bible_game/test_helpers/db_adapter_mock.dart';
import 'package:flutter/widgets.dart';
import 'package:redux/redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redux_thunk/redux_thunk.dart';

void main() {
  testWidgets("Game editor test", (WidgetTester tester) async {
    final store = Store<AppState>(
      mainReducer,
      initialState: AppState(
        dba: DbAdapterMock.withDefaultValues(),
        assetBundle: AssetBundleMock.withDefaultValue(),
        config: ConfigState.initialState(),
        explorer: ExplorerState(),
        game: GameState.emptyState(),
      ),
      middleware: [thunkMiddleware],
    );

    await tester.pumpWidget(BibleGame(store));
    await tester.pump(Duration(milliseconds: 10));
    // Check if the data loading is fine
    expect(store.state.game.list.length, 1);
    expect(store.state.game.books.length, 2);
    // Tap on the + button and open dialog
    await tester.tap(find.byKey(Key("showEditorDialog")));
    await tester.pump(Duration(seconds: 10));
    expect(store.state.game.dialogIsOpen, true);
  });
}
