import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:bible_game/main.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/config/state.dart';
import 'package:bible_game/redux/explorer/state.dart';
import 'package:bible_game/redux/games/state.dart';
import 'package:bible_game/redux/inventory/state.dart';
import 'package:bible_game/redux/main_reducer.dart';
import 'package:bible_game/test_helpers/asset_bundle.dart';
import 'package:bible_game/test_helpers/db_adapter_mock.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redux_thunk/redux_thunk.dart';

void main() {
  testWidgets("Quit single game basic flow", (WidgetTester tester) async {
    final store = Store<AppState>(
      mainReducer,
      initialState: AppState(
        games: GamesState.emptyState(),
        dba: DbAdapterMock.withDefaultValues(),
        assetBundle: AssetBundleMock.withDefaultValue(),
        explorer: ExplorerState(),
        config: ConfigState.initialState(),
        inventory: InventoryState.emptyState(),
      ),
      middleware: [thunkMiddleware],
    );
    await tester.pumpWidget(BibleGame(store));
    final wordsInWodBtn = find.byKey(Key("goToWordsInWordBtn"));
    final wordsInWordScreen = find.byKey(Key("wordsInWord"));
    final dialogScreen = find.byKey(Key("confirmQuitSingleGame"));
    final loaderScreen = find.byKey(Key("loader"));
    final homeScreen = find.byKey(Key("home"));
    final inventoryScreen = find.byKey(Key("inventoryDialog"));
    final yesBtn = find.byKey(Key("dialogYesBtn"));
    final noBtn = find.byKey(Key("dialogNoBtn"));
    final inventoryBtn = find.byKey(Key("inventoryBtn"));

    expect(loaderScreen, findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(homeScreen, findsOneWidget);
    await tester.tap(wordsInWodBtn);
    await tester.pump();
    expect(homeScreen, findsNothing);
    expect(wordsInWordScreen, findsOneWidget);
    // Press back button twice
    await BackButtonInterceptor.popRoute();
    await tester.pump();
    expect(dialogScreen, findsOneWidget);
    await BackButtonInterceptor.popRoute();
    await tester.pump();
    expect(dialogScreen, findsNothing);
    // Open dialog and tap NO
    await BackButtonInterceptor.popRoute();
    await tester.pump();
    await tester.tap(noBtn);
    await tester.pump();
    expect(wordsInWordScreen, findsOneWidget);
    // Open dialog and tap YES
    await BackButtonInterceptor.popRoute();
    await tester.pump();
    await tester.tap(yesBtn);
    await tester.pump();
    expect(homeScreen, findsOneWidget);

    // Open inventory and press back btn and tap yes
    await tester.tap(inventoryBtn);
    await tester.pump();
    expect(inventoryScreen, findsOneWidget);
    await BackButtonInterceptor.popRoute();
    await tester.pump(Duration(milliseconds: 10));
    expect(inventoryScreen, findsNothing);
  });
}
