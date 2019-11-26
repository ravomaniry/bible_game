import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:bible_game/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets("Quit single game basic flow", (WidgetTester tester) async {
    await tester.pumpWidget(BibleGame());
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
