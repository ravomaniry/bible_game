import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:bible_game/app/help/components/text/models.dart';
import 'package:bible_game/main.dart';
import 'package:bible_game/test_helpers/store.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  testWidgets("Help: init - parse - render - back", (tester) async {
    final store = newMockedStore();
    final json = '['
        '  {'
        '    "type": "text",'
        '    "title": "1",'
        '    "paragraphs": ['
        '      { "subtitle": "1.1", "body": "1.1 body" },'
        '      { "subtitle": "1.2", "body": "1.2 body" }'
        '    ]'
        '  }'
        ']';
    when(store.state.assetBundle.loadString("assets/help.json")).thenAnswer(
      (_) async {
        await Future.delayed(Duration(seconds: 1));
        return json;
      },
    );

    await tester.pumpWidget(BibleGame(store));
    await tester.pump(Duration(seconds: 1));
    await tester.tap(find.byKey(Key("goToHelp")));
    await tester.pump();
    // loading ...
    expect(store.state.help, null);
    await tester.pump(Duration(seconds: 2));

    /// Load and parse value
    expect(store.state.help.value, [
      TextContent("1", [
        ParagraphContent("1.1", "1.1 body"),
        ParagraphContent("1.2", "1.2 body"),
      ]),
    ]);

    /// display help screen
    expect(find.byKey(Key("helpScreen")), findsOneWidget);

    /// Press back and goes to home
    BackButtonInterceptor.popRoute();
    await tester.pump(Duration(seconds: 1));
    expect(find.byKey(Key("home")), findsOneWidget);
  });
}
