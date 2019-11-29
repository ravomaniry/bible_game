import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/calculator/state.dart';
import 'package:bible_game/redux/config/state.dart';
import 'package:bible_game/redux/explorer/state.dart';
import 'package:bible_game/redux/main_reducer.dart';
import 'package:bible_game/test_helpers/asset_bundle.dart';
import 'package:bible_game/test_helpers/db_adapter_mock.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:bible_game/components/calculator/calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets("Calculator widget test", (WidgetTester tester) async {
    final Store<AppState> store = Store<AppState>(
      mainReducer,
      initialState: AppState(
        calculator: CalculatorState(),
        dba: DbAdapterMock(),
        assetBundle: AssetBundleMock(),
        explorer: ExplorerState(),
        config: ConfigState.initialState(),
      ),
    );
    await tester.pumpWidget(
      StoreProvider<AppState>(
          store: store,
          child: MaterialApp(
            title: 'Flutter Calculator',
            home: Calculator(),
          )),
    );
    final outputFinder = find.byKey(Key('output'));
    final aText = find.byKey(Key("a"));
    final operatorText = find.byKey(Key("operator"));
    final button1 = find.byKey(Key("1"));
    final button5 = find.byKey(Key("5"));
    final button8 = find.byKey(Key("8"));
    final doubleZero = find.byKey(Key("00"));
    final plusBtn = find.byKey(Key("+"));
    final minusBtn = find.byKey(Key("-"));
    final equalBtn = find.byKey(Key("="));
    final divideBtn = find.byKey(Key("/"));
    final multiplyBtn = find.byKey(Key("*"));
    final clearBtn = find.byKey(Key("CLEAR"));
    final delBtn = find.byKey(Key("DEL"));

    expect((outputFinder.evaluate().single.widget as Text).data, "");
    await tester.tap(button1);
    await tester.pump();
    expect((outputFinder.evaluate().single.widget as Text).data, "1");
    await tester.tap(button5);
    await tester.pump();
    expect((outputFinder.evaluate().single.widget as Text).data, "15");
    await tester.tap(plusBtn);
    await tester.pump();
    expect((outputFinder.evaluate().single.widget as Text).data, "");
    expect((aText.evaluate().single.widget as Text).data, "15.0");
    expect((operatorText.evaluate().single.widget as Text).data, "+");
    await tester.tap(button8);
    await tester.pump();
    expect((outputFinder.evaluate().single.widget as Text).data, "8");
    await tester.tap(minusBtn);
    await tester.pump();
    expect((outputFinder.evaluate().single.widget as Text).data, "23.0");
    await tester.tap(button1);
    await tester.pump();
    expect((outputFinder.evaluate().single.widget as Text).data, "1");
    await tester.tap(equalBtn);
    await tester.pump();
    expect((outputFinder.evaluate().single.widget as Text).data, "22.0");
    await tester.tap(clearBtn);
    await tester.pump();
    expect((outputFinder.evaluate().single.widget as Text).data, "");

    await tester.tap(button5);
    await tester.tap(equalBtn);
    await tester.pump();
    expect((outputFinder.evaluate().single.widget as Text).data, "5.0");
    expect((aText.evaluate().single.widget as Text).data, "0.0");
    expect((operatorText.evaluate().single.widget as Text).data, "");

    await tester.tap(clearBtn);
    await tester.tap(button5);
    await tester.tap(doubleZero);
    await tester.tap(button8);
    await tester.tap(delBtn);
    await tester.pump();
    expect((outputFinder.evaluate().single.widget as Text).data, "500");
    await tester.tap(divideBtn);
    await tester.tap(button5);
    await tester.tap(multiplyBtn);
    await tester.pump();
    expect((outputFinder.evaluate().single.widget as Text).data, "100.0");
    await tester.tap(button8);
    await tester.tap(equalBtn);
    await tester.pump();
    expect((outputFinder.evaluate().single.widget as Text).data, "800.0");
  });
}
