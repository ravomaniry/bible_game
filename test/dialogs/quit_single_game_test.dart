import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:bible_game/main.dart';
import 'package:bible_game/redux/app_state.dart';
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
      initialState: AppState(dba: DbAdapterMock.withDefaultValues(), assetBundle: AssetBundleMock.withDefaultValue()),
      middleware: [thunkMiddleware],
    );
    await tester.pumpWidget(BibleGame(store));
    final wordsInWodBtn = find.byKey(Key("goToWordsInWordBtn"));
    final homeScreen = find.byKey(Key("home"));
    final wordsInWordScreen = find.byKey(Key("wordsInWord"));
    final dialogScreen = find.byKey(Key("confirmQuitSingleGame"));
    final yesBtn = find.byKey(Key("dialogYesBtn"));
    final noBtn = find.byKey(Key("dialogNoBtn"));

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
  });
}
