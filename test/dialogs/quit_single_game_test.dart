import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:bible_game/main.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/config/state.dart';
import 'package:bible_game/redux/editor/state.dart';
import 'package:bible_game/redux/explorer/state.dart';
import 'package:bible_game/redux/game/actions.dart';
import 'package:bible_game/redux/game/state.dart';
import 'package:bible_game/redux/main_reducer.dart';
import 'package:bible_game/redux/themes/themes.dart';
import 'package:bible_game/test_helpers/asset_bundle.dart';
import 'package:bible_game/test_helpers/db_adapter_mock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

void main() {
  testWidgets("Quit single game basic flow", (WidgetTester tester) async {
    final store = Store<AppState>(
      mainReducer,
      initialState: AppState(
        editor: EditorState(),
        theme: AppColorTheme(),
        game: GameState.emptyState(),
        dba: DbAdapterMock.withDefaultValues(),
        assetBundle: AssetBundleMock.withDefaultValue(),
        explorer: ExplorerState(),
        config: ConfigState.initialState(),
      ),
      middleware: [thunkMiddleware],
    );
    await tester.pumpWidget(BibleGame(store));
    final wordsInWordScreen = find.byKey(Key("wordsInWord"));
    final dialogScreen = find.byKey(Key("confirmQuitSingleGame"));
    final loaderScreen = find.byKey(Key("loader"));
    final homeScreen = find.byKey(Key("home"));
    final inventoryScreen = find.byKey(Key("inventoryDialog"));
    final yesBtn = find.byKey(Key("dialogYesBtn"));
    final noBtn = find.byKey(Key("dialogNoBtn"));

    // On startup => splash screen is shown
    expect(loaderScreen, findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(homeScreen, findsOneWidget);
    // Go to game 1 -- details are tested in navigation test
    await tester.tap(find.byKey(Key("game_1")));
    await tester.pump(Duration(milliseconds: 10));
    expect(homeScreen, findsNothing);
    expect(inventoryScreen, findsOneWidget);

    // Press back button on Inventory goes back to home
    await BackButtonInterceptor.popRoute();
    await tester.pump();
    expect(inventoryScreen, findsNothing);
    expect(homeScreen, findsOneWidget);
    expect(dialogScreen, findsNothing);

    // Open game again and close inventory
    await tester.tap(find.byKey(Key("game_1")));
    await tester.pump(Duration(milliseconds: 10));
    expect(inventoryScreen, findsOneWidget);
    await tester.tap(find.byKey(Key("inventoryOkButton")));
    await tester.pump();

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

    // Go to game 1 => close dialog => resolve game => press back => should go to home
    verify(store.state.dba.saveGame(any)).called(1);
    await tester.tap(find.byKey(Key("game_1")));
    await tester.pump(Duration(milliseconds: 10));
    await tester.tap(find.byKey(Key("inventoryOkButton")));
    await tester.pump(Duration(milliseconds: 10));
    store.dispatch(UpdateGameResolvedState(true));
    await tester.pump(Duration(milliseconds: 10));
    expect(find.byKey(Key("solutionScreen")), findsOneWidget);
    await BackButtonInterceptor.popRoute();
    await tester.pump(Duration(milliseconds: 10));
    expect(homeScreen, findsOneWidget);
    verify(store.state.dba.saveGame(any)).called(2);
  });
}
