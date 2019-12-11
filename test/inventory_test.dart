import 'package:bible_game/main.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/config/state.dart';
import 'package:bible_game/redux/explorer/state.dart';
import 'package:bible_game/redux/games/state.dart';
import 'package:bible_game/redux/inventory/state.dart';
import 'package:bible_game/redux/main_reducer.dart';
import 'package:bible_game/test_helpers/asset_bundle.dart';
import 'package:bible_game/test_helpers/db_adapter_mock.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

void main() {
  testWidgets("Invenrory - Basic flow", (WidgetTester tester) async {
    final store = Store<AppState>(
      mainReducer,
      middleware: [thunkMiddleware],
      initialState: AppState(
        games: GamesListState.emptyState(),
        assetBundle: AssetBundleMock.withDefaultValue(),
        dba: DbAdapterMock.withDefaultValues(),
        config: ConfigState.initialState(),
        explorer: ExplorerState(),
        inventory: InventoryState.emptyState().copyWith(money: 500),
      ),
    );

    final inventoryFinder = find.byKey(Key("inventoryDialog"));

    await tester.pumpWidget(BibleGame(store));
    await tester.pump(Duration(milliseconds: 100));
    expect(inventoryFinder, findsNothing);
    await tester.tap(find.byKey(Key("inventoryBtn")));
    await tester.pump();
    expect(inventoryFinder, findsOneWidget);

    // buy bonuses
    await tester.tap(find.byKey(Key("revealCharBonusBtn_1")));
    await tester.tap(find.byKey(Key("revealCharBonusBtn_1")));
    await tester.pump(Duration(milliseconds: 200));
    expect(store.state.inventory.money, 490);
    expect(store.state.inventory.revealCharBonus1, 2);

    await tester.tap(find.byKey(Key("revealCharBonusBtn_2")));
    await tester.tap(find.byKey(Key("revealCharBonusBtn_5")));
    await tester.tap(find.byKey(Key("revealCharBonusBtn_5")));
    await tester.tap(find.byKey(Key("revealCharBonusBtn_5")));
    await tester.tap(find.byKey(Key("revealCharBonusBtn_10")));
    await tester.tap(find.byKey(Key("revealCharBonusBtn_10")));
    await tester.tap(find.byKey(Key("revealCharBonusBtn_10")));
    await tester.tap(find.byKey(Key("revealCharBonusBtn_10")));

    expect(store.state.inventory.money, 393);
    expect(store.state.inventory.revealCharBonus1, 2);
    expect(store.state.inventory.revealCharBonus2, 1);
    expect(store.state.inventory.revealCharBonus5, 3);
    expect(store.state.inventory.revealCharBonus10, 4);

    // Tap bonus button too many times
    for (int i = 0; i < 10; i++) {
      await tester.tap(find.byKey(Key("solveOneTurnBonusBtn")));
    }
    expect(store.state.inventory.money, 43);
    expect(store.state.inventory.solveOneTurnBonus, 7);

    // close the dialog
    await tester.tap(find.byKey(Key("inventoryOkButton")));
    await tester.pump();
    expect(inventoryFinder, findsNothing);
  });
}
