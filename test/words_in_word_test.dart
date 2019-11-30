import 'package:bible_game/db/model.dart';
import 'package:bible_game/main.dart';
import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/cell.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/config/actions.dart';
import 'package:bible_game/redux/config/state.dart';
import 'package:bible_game/redux/explorer/state.dart';
import 'package:bible_game/redux/main_reducer.dart';
import 'package:bible_game/redux/words_in_word/actions.dart';
import 'package:bible_game/redux/words_in_word/logics.dart';
import 'package:bible_game/test_helpers/asset_bundle.dart';
import 'package:bible_game/test_helpers/db_adapter_mock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

void main() {
  testWidgets("Words in word intial state", (WidgetTester tester) async {
    final state = AppState(
      assetBundle: AssetBundleMock.withDefaultValue(),
      dba: DbAdapterMock.withDefaultValues(),
      explorer: ExplorerState(),
      config: ConfigState.initialState(),
    );
    final store = Store<AppState>(
      mainReducer,
      initialState: state,
      middleware: [thunkMiddleware],
    );
    await tester.pumpWidget(BibleGame(store));
    await tester.pump(Duration(milliseconds: 10)); // let the event loop tick to resolve futures
    await tester.tap(find.byKey(Key("goToWordsInWordBtn")));
    await tester.pump();
    await tester.pump(Duration(milliseconds: 10));
    expect(store.state.error == null, true);
    expect(store.state.wordsInWord.verse, BibleVerse.fromModel(await state.dba.getSingleVerse(1, 2, 3), "Genesisy"));
    expect(store.state.wordsInWord.resolvedWords, []);
    expect(store.state.wordsInWord.wordsToFind, [
      Word.from("Ny", 0, false),
      Word.from("filazana", 2, false),
      Word.from("ny", 4, false),
      Word.from("razan", 6, false),
      Word.from("i", 8, false),
      Word.from("Jesosy", 10, false),
      Word.from("Kristy", 12, false),
    ]);
    expect(store.state.wordsInWord.slots.length, 8);
    expect(store.state.wordsInWord.slotsBackup.length, 8);
    verify(store.state.dba.getSingleVerse(1, 1, 1)).called(1);
    verify(store.state.dba.getBookById(1)).called(1);
  });

  test("Get next verse", () async {
    final state = AppState(
      dba: DbAdapterMock(),
      assetBundle: AssetBundleMock.withDefaultValue(),
      explorer: ExplorerState(),
      config: ConfigState.initialState(),
    );
    final store = Store<AppState>(mainReducer, initialState: state, middleware: [thunkMiddleware]);

    when(state.dba.getBookById(1)).thenAnswer((_) => Future.value(Books(id: 1, name: "Genesisy", chapters: 10)));
    when(state.dba.getSingleVerse(1, 1, 1))
        .thenAnswer((_) => Future.value(Verses(id: 1, book: 1, chapter: 1, verse: 1, text: "TestA")));
    when(state.dba.getSingleVerse(1, 1, 2))
        .thenAnswer((_) => Future.value(Verses(id: 1, book: 1, chapter: 1, verse: 2, text: "TestB")));
    when(state.dba.getSingleVerse(1, 1, 3)).thenAnswer((_) => Future.value(null));
    when(state.dba.getSingleVerse(1, 2, 1))
        .thenAnswer((_) => Future.value(Verses(id: 1, book: 1, chapter: 2, verse: 1, text: "TestC.")));

    store.dispatch(goToWordsInWord);
    await Future.delayed(Duration(seconds: 1));
    var verse = BibleVerse.fromModel(Verses(id: 1, book: 1, chapter: 1, verse: 1, text: "TestA"), "Genesisy");
    expect(store.state.wordsInWord.verse, verse);
    verify(store.state.dba.getSingleVerse(1, 1, 1)).called(1);
    verify(store.state.dba.getBookById(1)).called(1);
    // Next should not call get book anymore
    verse = BibleVerse.fromModel(Verses(id: 1, book: 1, chapter: 1, verse: 2, text: "TestB"), "Genesisy");
    await loadWordsInWordNextVerse(store);
    store.dispatch(initializeWordsInWordState);
    await Future.delayed(Duration(seconds: 1));
    expect(store.state.wordsInWord.verse, verse);
    expect(store.state.wordsInWord.wordsToFind, verse.words);
    expect(store.state.wordsInWord.resolvedWords, []);
    verify(store.state.dba.getSingleVerse(1, 1, 2)).called(1);
    verifyNever(store.state.dba.getBookById(1));
    // Next should increment chapter
    await loadWordsInWordNextVerse(store);
    store.dispatch(initializeWordsInWordState);
    await Future.delayed(Duration(seconds: 1));
    expect(store.state.wordsInWord.verse,
        BibleVerse.fromModel(Verses(id: 1, book: 1, chapter: 2, verse: 1, text: "TestC."), "Genesisy"));
    verify(store.state.dba.getSingleVerse(1, 2, 1)).called(1);
    verifyNever(store.state.dba.getBookById(1));
  });

  test("Compute cells", () async {
    final store = Store<AppState>(
      mainReducer,
      middleware: [thunkMiddleware],
      initialState: AppState(
        dba: DbAdapterMock.withDefaultValues(),
        assetBundle: AssetBundleMock.withDefaultValue(),
        explorer: ExplorerState(),
        config: ConfigState.initialState(),
      ),
    );
    store.dispatch(UpdateScreenWidth(190));
    store.dispatch(goToWordsInWord);
    expect(store.state.config.screenWidth, 190);
    await Future.delayed(Duration(milliseconds: 10));
    final expectedCells = [
      [Cell(0, 0), Cell(0, 1), Cell(1, 0)],
      [Cell(2, 0), Cell(2, 1), Cell(2, 2), Cell(2, 3), Cell(2, 4), Cell(2, 5), Cell(2, 6), Cell(2, 7)],
      [Cell(3, 0), Cell(4, 0), Cell(4, 1), Cell(5, 0)],
      [Cell(6, 0), Cell(6, 1), Cell(6, 2), Cell(6, 3), Cell(6, 4), Cell(7, 0), Cell(8, 0), Cell(9, 0)],
      [Cell(10, 0), Cell(10, 1), Cell(10, 2), Cell(10, 3), Cell(10, 4), Cell(10, 5), Cell(11, 0)],
      [Cell(12, 0), Cell(12, 1), Cell(12, 2), Cell(12, 3), Cell(12, 4), Cell(12, 5)]
    ];
    expect(store.state.wordsInWord.cells, expectedCells);
  });
}
