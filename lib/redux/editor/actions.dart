import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/editor/state.dart';
import 'package:bible_game/redux/error/actions.dart';
import 'package:bible_game/redux/router/actions.dart';
import 'package:bible_game/redux/router/routes.dart';
import 'package:bible_game/statics/texts.dart';
import 'package:bible_game/utils/retry.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

class UpdateEditorState {
  final EditorState payload;

  UpdateEditorState(this.payload);
}

ThunkAction<AppState> goToEditor = (Store<AppState> store) {
  store.dispatch(GoToAction(Routes.gameEditor));
  store.dispatch(startBookChangeHandler(1));
};

ThunkAction<AppState> startBookChangeHandler(int bookId) {
  return (store) {
    store.dispatch(UpdateEditorState(store.state.editor.copyWith(startBook: bookId)));
    store.dispatch(startChapterChangeHandler(1));
  };
}

ThunkAction<AppState> startChapterChangeHandler(int chapter) {
  return (store) async {
    final state = store.state.editor;
    store.dispatch(UpdateEditorState(state.copyWith(
      startChapter: chapter,
      startVerse: 1,
    )));
    await loadVersesNum(state.startBook, chapter, store);
    store.dispatch(autoPopulateEndFields);
  };
}

ThunkAction<AppState> startVerseChangeHandler(int startVerse) {
  return (store) {
    store.dispatch(UpdateEditorState(store.state.editor.copyWith(startVerse: startVerse)));
    store.dispatch(autoPopulateEndFields);
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
    store.dispatch(autoSelectEndVerse);
  };
}

ThunkAction<AppState> endChapterChangeHandler(int chapter) {
  return (store) async {
    final state = store.state.editor;
    store.dispatch(UpdateEditorState(state.copyWith(endChapter: chapter)));
    await loadVersesNum(state.endBook, chapter, store);
    store.dispatch(autoSelectEndVerse);
  };
}

ThunkAction<AppState> endVerseChangeHandler(int endVerse) {
  return (store) {
    store.dispatch(UpdateEditorState(store.state.editor.copyWith(endVerse: endVerse)));
    print(store.state.editor.startVerse);
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
        store.dispatch(ReceiveError(Errors.unknownDbError));
      } else {
        store.dispatch(UpdateEditorState(
          store.state.editor.appendVersesNum(VersesNumRef(bookId, chapter, versesNum)),
        ));
      }
    } catch (e) {
      store.dispatch(ReceiveError(Errors.unknownDbError));
      print("%%%%%%%%%%% error in loadVersesNum %%%%%%%%%%%");
      print(e);
    }
  }
}

final ThunkAction<AppState> autoPopulateEndFields = (store) {
  final state = store.state.editor;
  final startBook = state.startBook;
  final startChapter = state.startChapter;
  final startVerse = state.startVerse;
  final endBook = state.endBook;
  final endChapter = state.endChapter;
  final endVerse = state.endVerse;

  if (startBook > endBook || (startBook == endBook && startChapter < endChapter)) {
    store.dispatch(endBookChangeHandler(startBook));
  } else if (endBook == startBook && endChapter == startChapter && endVerse <= startVerse) {
    store.dispatch(endChapterChangeHandler(startChapter));
  }
};

final ThunkAction<AppState> autoSelectEndVerse = (store) {
  final state = store.state.editor;
  final match = state.versesNumRefs.where((n) => n.isSameRef(state.endBook, state.endChapter)).toList();
  if (match.isEmpty) {
    store.dispatch(UpdateEditorState(state.copyWith(endVerse: 1)));
  } else {
    store.dispatch(UpdateEditorState(state.copyWith(endVerse: match.first.versesNum)));
  }
};

ThunkAction<AppState> closeEditor = (Store<AppState> store) async {
  store.dispatch(goToHome);
  final state = store.state.editor;
  final versesCount = await store.state.dba.getVersesNumBetween(
    startBook: state.startBook,
    startChapter: state.startChapter,
    startVerse: state.startVerse,
    endBook: state.endBook,
    endChapter: state.endChapter,
    endVerse: state.endVerse,
  );
};
