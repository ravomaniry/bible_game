import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:bible_game/app/help/models.dart';
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
        '    "type": "section",'
        '    "title": "1",'
        '    "contents": ['
        '      {'
        '         "type": "paragraph",'
        '         "title": "1.1",'
        '         "text": "1.1 body"'
        '      },'
        '      {'
        '        "type": "gallery",'
        '        "title": "1.2",'
        '        "images": ['
        '          {"title": "1.2.1", "path": "121.jpg"},'
        '          {"title": "1.2.2", "path": "122.jpg"}'
        '        ]'
        '      },'
        '      {'
        '        "type": "paragraph",'
        '        "title": "1.3",'
        '        "text": "1.3 body"'
        '      },'
        '      {'
        '        "type": "ingored",'
        '        "title": "Ingored"'
        '      }'
        '    ]'
        '  },'
        '  {'
        '    "type": "gallery",'
        '    "images": ['
        '      {'
        '        "title": "hello",'
        '        "path": "world.jpg"'
        '      }'
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
    expect(store.state.help.value, <HelpUiItem>[
      HelpSection("1", [
        HelpParagraph("1.1", "1.1 body"),
        HelpGallery(
          "1.2",
          [HelpGalleryImage("1.2.1", "121.jpg"), HelpGalleryImage("1.2.2", "122.jpg")],
        ),
        HelpParagraph("1.3", "1.3 body"),
      ]),
      HelpGallery("", [HelpGalleryImage("hello", "world.jpg")]),
    ]);

    /// display help screen
    expect(find.byKey(Key("helpScreen")), findsOneWidget);

    /// Press back and goes to home
    BackButtonInterceptor.popRoute();
    await tester.pump(Duration(seconds: 1));
    expect(find.byKey(Key("home")), findsOneWidget);

    await tester.tap(find.byKey(Key("goToHelp")));
    await tester.pump(Duration(seconds: 1));
    expect(find.byKey(Key("helpScreen")), findsOneWidget);
    await tester.tap(find.byKey(Key("closeHelpBtn")));
    await tester.pump();
    expect(find.byKey(Key("home")), findsOneWidget);
  });
}
