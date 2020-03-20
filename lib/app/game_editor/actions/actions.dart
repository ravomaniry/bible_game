import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/error/actions.dart';
import 'package:bible_game/app/game/actions/init.dart';
import 'package:bible_game/app/game_editor/actions/action_creators.dart';
import 'package:bible_game/app/game_editor/reducer/state.dart';
import 'package:bible_game/app/inventory/reducer/state.dart';
import 'package:bible_game/app/router/actions.dart';
import 'package:bible_game/app/router/routes.dart';
import 'package:bible_game/db/model.dart';
import 'package:bible_game/models/game.dart';
import 'package:bible_game/statics/texts.dart';
import 'package:bible_game/utils/retry.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

ThunkAction<AppState> goToEditor() {
  return (Store<AppState> store) {
    store.dispatch(GoToAction(Routes.gameEditor));
    store.dispatch(startBookChangeHandler(1));
  };
}

ThunkAction<AppState> handleBackButtonPress() {
  return (store) {
    if (store.state.route == Routes.gameEditor) {
      store.dispatch(goToHome());
    }
  };
}

ThunkAction<AppState> startBookChangeHandler(int bookId) {
  return (store) {
    store.dispatch(UpdateEditorState(store.state.editor.copyWith(startBook: bookId)));
    store.dispatch(startChapterChangeHandler(1));
  };
}

ThunkAction<AppState> startChapterChangeHandler(int chapter) {
  return (store) async {
    final state = store.state.editor;
    var endChapter = state.endChapter;
    var endVerse = state.endVerse;
    if (state.startBook == state.endBook && endChapter < chapter) {
      endChapter = chapter;
      endVerse = 1;
    }
    store.dispatch(UpdateEditorState(state.copyWith(
      startChapter: chapter,
      startVerse: 1,
      endChapter: endChapter,
      endVerse: endVerse,
    )));
    await loadVersesNum(state.startBook, chapter, store);
    store.dispatch(_autoPopulateEndFields());
  };
}

ThunkAction<AppState> startVerseChangeHandler(int startVerse) {
  return (store) {
    store.dispatch(UpdateEditorState(store.state.editor.copyWith(startVerse: startVerse)));
    store.dispatch(_autoPopulateEndFields());
  };
}

ThunkAction<AppState> endBookChangeHandler(int bookId) {
  return (store) async {
    final book = store.state.game.books.firstWhere((b) => b.id == bookId);
    final state = store.state.editor;
    store.dispatch(UpdateEditorState(state.copyWith(
      endBook: bookId,
      endChapter: book.chapters,
      endVerse: 1,
    )));
    await loadVersesNum(bookId, book.chapters, store);
    store.dispatch(_autoSelectEndVerse());
  };
}

ThunkAction<AppState> endChapterChangeHandler(int chapter) {
  return (store) async {
    final state = store.state.editor;
    store.dispatch(UpdateEditorState(state.copyWith(endChapter: chapter)));
    await loadVersesNum(state.endBook, chapter, store);
    store.dispatch(_autoSelectEndVerse());
  };
}

ThunkAction<AppState> endVerseChangeHandler(int endVerse) {
  return (store) {
    store.dispatch(UpdateEditorState(store.state.editor.copyWith(endVerse: endVerse)));
  };
}

Future loadVersesNum(int bookId, int chapter, Store<AppState> store) async {
  final state = store.state.editor;
  final dba = store.state.dba;
  final numbers = state.versesNumRefs.where((n) => n.isSameRef(bookId, chapter));
  if (numbers.isEmpty) {
    try {
      final versesNum = await retry(() => dba.getChapterVersesCount(bookId, chapter));
      if (versesNum == null) {
        store.dispatch(ReceiveError(Errors.unknownDbError()));
      } else {
        store.dispatch(UpdateEditorState(
          store.state.editor.appendVersesNum(VersesNumRef(bookId, chapter, versesNum)),
        ));
      }
    } catch (e) {
      store.dispatch(ReceiveError(Errors.unknownDbError()));
      print("%%%%%%%%%%% error in loadVersesNum %%%%%%%%%%%");
      print(e);
    }
  }
}

ThunkAction<AppState> _autoPopulateEndFields() {
  return (store) {
    final state = store.state.editor;
    final startBook = state.startBook;
    final startChapter = state.startChapter;
    final startVerse = state.startVerse;
    final endBook = state.endBook;
    final endChapter = state.endChapter;
    final endVerse = state.endVerse;

    if (startBook > endBook || (startBook == endBook && startChapter < endChapter)) {
      store.dispatch(endBookChangeHandler(startBook));
    } else if (endBook == startBook && endChapter <= startChapter && endVerse <= startVerse) {
      store.dispatch(endChapterChangeHandler(startChapter));
    }
  };
}

ThunkAction<AppState> _autoSelectEndVerse() {
  return (store) {
    final state = store.state.editor;
    final match =
        state.versesNumRefs.where((n) => n.isSameRef(state.endBook, state.endChapter)).toList();
    if (match.isEmpty) {
      store.dispatch(UpdateEditorState(state.copyWith(endVerse: 1)));
    } else {
      store.dispatch(UpdateEditorState(state.copyWith(endVerse: match.first.versesNum)));
    }
  };
}

ThunkAction<AppState> closeEditor() {
  return (store) {
    store.dispatch(goToHome());
    store.dispatch(_saveNewGame());
  };
}

ThunkAction<AppState> _saveNewGame() {
  return (store) async {
    final state = store.state.editor;
    try {
      final versesCount = await store.state.dba.getVersesNumBetween(
        startBook: state.startBook,
        startChapter: state.startChapter,
        startVerse: state.startVerse,
        endBook: state.endBook,
        endChapter: state.endChapter,
        endVerse: state.endVerse,
      );
      if (versesCount == null) {
        store.dispatch(Errors.unknownDbError());
      } else {
        final books = store.state.game.books;
        final startBookName = books.firstWhere((b) => b.id == state.startBook).name;
        final endBookName = books.firstWhere((b) => b.id == state.endBook).name;
        final name = "$startBookName ${state.startChapter}:${state.startVerse} - "
            "$endBookName ${state.endChapter}:${state.endVerse}";
        final model = GameModelWrapper(
          nextBook: state.startBook,
          nextChapter: state.startChapter,
          nextVerse: state.startVerse,
          resolvedVersesCount: 0,
          startBookName: startBookName,
          endBookName: endBookName,
          inventory: InventoryState(
            money: 0,
            combo: 1,
            isOpen: false,
            revealCharBonus1: 10,
            revealCharBonus2: 10,
            revealCharBonus5: 5,
            revealCharBonus10: 5,
            solveOneTurnBonus: 0,
          ),
          model: GameModel(
            name: name,
            startBook: state.startBook,
            startChapter: state.startChapter,
            startVerse: state.startVerse,
            endBook: state.endBook,
            endChapter: state.endChapter,
            endVerse: state.endVerse,
            versesCount: versesCount,
            bonuses: "{}",
          ),
        ).toModelHelper();
        await store.state.dba.saveGame(model);
        await initializeGamesList(store.state.dba, books, store.dispatch);
      }
    } catch (e) {
      print("%%%%%%%%%% error in closeEditor %%%%%%%%%%");
      print(e);
      store.dispatch(Errors.unknownDbError());
    }
  };
}
