import 'package:bible_game/redux/config/state.dart';
import 'package:bible_game/redux/explorer/state.dart';
import 'package:bible_game/redux/inventory/state.dart';
import 'package:bible_game/test_helpers/asset_bundle.dart';
import 'package:bible_game/main.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/main_reducer.dart';
import 'package:bible_game/redux/router/actions.dart';
import 'package:bible_game/redux/router/routes.dart';
import 'package:bible_game/test_helpers/db_adapter_mock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

void main() {
  test("Router", () {
    final state = mainReducer(
        AppState(
          explorer: ExplorerState(),
          dba: DbAdapterMock.withDefaultValues(),
          assetBundle: AssetBundleMock(),
          config: ConfigState.initialState(),
          inventory: InventoryState.emptyState(),
        ),
        null);
    final action = goToCalculator;
    final nextState = mainReducer(state, action);
    expect(nextState.route, Routes.calculator);
  });

  testWidgets("Router basic go to calculator", (WidgetTester tester) async {
    final store = Store<AppState>(
      mainReducer,
      middleware: [thunkMiddleware],
      initialState: AppState(
        dba: DbAdapterMock.withDefaultValues(),
        assetBundle: AssetBundleMock(),
        explorer: ExplorerState(),
        config: ConfigState.initialState(),
        inventory: InventoryState.emptyState(),
      ),
    );
    final homeFinder = find.byKey(Key("home"));
    final calculatorFinder = find.byKey(Key("calculator"));
    final goToCalculatorBtn = find.byKey(Key("goToCalculatorBtn"));

    await tester.pumpWidget(BibleGame(store));
    await tester.pump(Duration(seconds: 1));
    expect(homeFinder, findsOneWidget);

    await tester.tap(goToCalculatorBtn);
    await tester.pump();
    expect(calculatorFinder, findsOneWidget);
  });

  testWidgets("Router basic go to Words in word", (WidgetTester tester) async {
    final store = Store<AppState>(
      mainReducer,
      middleware: [thunkMiddleware],
      initialState: AppState(
        dba: DbAdapterMock.withDefaultValues(),
        assetBundle: AssetBundleMock(),
        explorer: ExplorerState(),
        config: ConfigState.initialState(),
        inventory: InventoryState.emptyState(),
      ),
    );
    final wordsInWordFinder = find.byKey(Key("wordsInWord"));
    final goToWordsInWordBtn = find.byKey(Key("goToWordsInWordBtn"));

    await tester.pumpWidget(BibleGame(store));
    await tester.pump(Duration(seconds: 1));
    await tester.tap(goToWordsInWordBtn);
    await tester.pump();
    expect(wordsInWordFinder, findsOneWidget);
  });

  testWidgets("Router basic go to Explorer", (WidgetTester tester) async {
    final store = Store<AppState>(
      mainReducer,
      middleware: [thunkMiddleware],
      initialState: AppState(
        dba: DbAdapterMock.withDefaultValues(),
        assetBundle: AssetBundleMock(),
        explorer: ExplorerState(),
        config: ConfigState.initialState(),
        inventory: InventoryState.emptyState(),
      ),
    );
    final explorerFinder = find.byKey(Key("explorer"));
    final explorerBtn = find.byKey(Key("goToExplorer"));

    await tester.pumpWidget(BibleGame(store));
    await tester.pump(Duration(seconds: 1));
    await tester.tap(explorerBtn);
    await tester.pump();
    expect(explorerFinder, findsOneWidget);
  });
}
