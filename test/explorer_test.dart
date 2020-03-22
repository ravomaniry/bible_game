import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:bible_game/main.dart';
import 'package:bible_game/test_helpers/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'game_editor_test.dart';

void main() {
  testWidgets("Explorer widget test", (WidgetTester tester) async {
    final store = newMockedStore();
    final loaderFinder = find.byKey(Key("loader"));
    final explorerFinder = find.byKey(Key("explorer"));
    final explorerBtn = find.byKey(Key("goToExplorer"));
    final versesDisplay = find.byKey(Key("explorerVersesDisplay"));
    final form = find.byKey(Key("explorerForm"));

    await tester.pumpWidget(BibleGame(store));
    expect(loaderFinder, findsOneWidget);

    await tester.pump(Duration(seconds: 1));
    await tester.tap(explorerBtn);
    await tester.pump();
    expect(explorerFinder, findsOneWidget);
    expect(form, findsOneWidget);
    expect(versesDisplay, findsNothing);
    expect(store.state.dbState.isReady, true);
    expect(store.state.game.books.length, 2);

    /// select verse and load: book 2: 3: 4
    await selectDdItem(tester, "explorerBook_2");
    await selectDdItem(tester, "explorerChapter_3");
    await selectDdItem(tester, "explorerVerse_4");
    expect(store.state.explorer.activeBook, 2);
    expect(store.state.explorer.activeChapter, 3);
    expect(store.state.explorer.activeVerse, 4);

    /// Submit and expect dba to be called with the correct arguments
    await tester.tap(find.byKey(Key("editorOkBtn")));
    await tester.pump(Duration(milliseconds: 10));
    verify(store.state.dba.getVerses(2, chapter: 3, verse: 4)).called(1);
    expect(versesDisplay, findsOneWidget);
    expect(store.state.explorer.verses.length, 1);

    /// Now pressing back buttons should => show form => go to home
    BackButtonInterceptor.popRoute();
    await tester.pump(Duration(milliseconds: 10));
    expect(versesDisplay, findsNothing);
    expect(form, findsOneWidget);
    BackButtonInterceptor.popRoute();
    await tester.pump(Duration(milliseconds: 10));
    expect(explorerFinder, findsNothing);
    expect(find.byKey(Key("home")), findsOneWidget);
  });
}
