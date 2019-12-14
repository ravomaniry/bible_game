import 'package:bible_game/db/model.dart';
import 'package:bible_game/main.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/config/state.dart';
import 'package:bible_game/redux/explorer/state.dart';
import 'package:bible_game/redux/game/state.dart';
import 'package:bible_game/redux/inventory/state.dart';
import 'package:bible_game/redux/main_reducer.dart';
import 'package:bible_game/test_helpers/asset_bundle.dart';
import 'package:bible_game/test_helpers/db_adapter_mock.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

void main() {
  testWidgets("Invenrory - Basic flow", (WidgetTester tester) async {
    final dba = DbAdapterMock.mockMethods(DbAdapterMock(), [
      "init",
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
      "getBookVersesCount",
    ]);
    final store = Store<AppState>(
      mainReducer,
      middleware: [thunkMiddleware],
      initialState: AppState(
        game: GameState.emptyState().copyWith(
          inventory: InventoryState.emptyState(),
        ),
        assetBundle: AssetBundleMock.withDefaultValue(),
        dba: dba,
        config: ConfigState.initialState(),
        explorer: ExplorerState(),
      ),
    );
    final game = GameModel(
      id: 1,
      name: "A",
      money: 500,
      bonuses: "{}",
      resolvedVersesCount: 0,
      versesCount: 10,
      nextVerse: 1,
      nextBook: 1,
      nextChapter: 1,
      endVerse: 10,
      endChapter: 10,
      endBook: 1,
      startBook: 1,
      startVerse: 1,
      startChapter: 1,
    );
    when(dba.games).thenAnswer((_) => Future.value([game]));

    await tester.pumpWidget(BibleGame(store));
    await tester.pump(Duration(milliseconds: 100));
    final inventoryFinder = find.byKey(Key("inventoryDialog"));

    // Select the first game and to the shopping there
    expect(inventoryFinder, findsNothing);
    await tester.tap(find.byKey(Key("game_1")));
    await tester.pump();
    expect(inventoryFinder, findsOneWidget);
    // buy bonuses
    await tester.tap(find.byKey(Key("revealCharBonusBtn_1")));
    await tester.tap(find.byKey(Key("revealCharBonusBtn_1")));
    await tester.pump(Duration(milliseconds: 200));
    expect(store.state.game.inventory.money, 490);
    expect(store.state.game.inventory.revealCharBonus1, 2);

    await tester.tap(find.byKey(Key("revealCharBonusBtn_2")));
    await tester.tap(find.byKey(Key("revealCharBonusBtn_5")));
    await tester.tap(find.byKey(Key("revealCharBonusBtn_5")));
    await tester.tap(find.byKey(Key("revealCharBonusBtn_5")));
    await tester.tap(find.byKey(Key("revealCharBonusBtn_10")));
    await tester.tap(find.byKey(Key("revealCharBonusBtn_10")));
    await tester.tap(find.byKey(Key("revealCharBonusBtn_10")));
    await tester.tap(find.byKey(Key("revealCharBonusBtn_10")));

    expect(store.state.game.inventory.money, 393);
    expect(store.state.game.inventory.revealCharBonus1, 2);
    expect(store.state.game.inventory.revealCharBonus2, 1);
    expect(store.state.game.inventory.revealCharBonus5, 3);
    expect(store.state.game.inventory.revealCharBonus10, 4);

    // Tap bonus button too many times
    for (int i = 0; i < 10; i++) {
      await tester.tap(find.byKey(Key("solveOneTurnBonusBtn")));
    }
    expect(store.state.game.inventory.money, 43);
    expect(store.state.game.inventory.solveOneTurnBonus, 7);

    // close the dialog
    await tester.tap(find.byKey(Key("inventoryOkButton")));
    await tester.pump();
    expect(inventoryFinder, findsNothing);
  });
}
