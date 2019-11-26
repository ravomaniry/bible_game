import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:bible_game/main.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/main_reducer.dart';
import 'package:bible_game/redux/router/actions.dart';
import 'package:bible_game/redux/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Router", () {
    final state = mainReducer(AppState.initialState(), null);
    final action = goToCalculator;
    final nextState = mainReducer(state, action);
    expect(nextState.route, Routes.calculator);
  });

  testWidgets("Router basic go to calculator", (WidgetTester tester) async {
    await tester.pumpWidget(BibleGame());
    final homeFinder = find.byKey(Key("home"));
    final calculatorFinder = find.byKey(Key("calculator"));
    final goToCalculatorBtn = find.byKey(Key("goToCalculatorBtn"));

    expect(homeFinder, findsOneWidget);
    await tester.tap(goToCalculatorBtn);
    await tester.pump();
    expect(calculatorFinder, findsOneWidget);
  });

  testWidgets("Router basic go to Words in word", (WidgetTester tester) async {
    await tester.pumpWidget(BibleGame());
    final wordsInWordFinder = find.byKey(Key("wordsInWord"));
    final goToWordsInWordBtn = find.byKey(Key("goToWordsInWordBtn"));

    await tester.tap(goToWordsInWordBtn);
    await tester.pump();
    expect(wordsInWordFinder, findsOneWidget);
  });
}
