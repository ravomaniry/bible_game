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
  return (Store<AppState> store) {
    store.dispatch(UpdateEditorState(store.state.editor.copyWith(startBook: bookId)));
    store.dispatch(startChapterChangeHandler(1));
  };
}

ThunkAction<AppState> startChapterChangeHandler(int chapter) {
  return (Store<AppState> store) async {
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
  return (Store<AppState> store) {
    store.dispatch(UpdateEditorState(store.state.editor.copyWith(
      startVerse: startVerse,
    )));
    store.dispatch(autoPopulateEndFields);
  };
}

Future loadVersesNum(int bookId, int chapter, Store<AppState> store) async {
  final state = store.state.editor;
  final dba = store.state.dba;
  final numbers = state.versesNumRefs.where((n) => n.isSameRef(bookId, chapter));
  if (numbers.length == 0) {
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

ThunkAction<AppState> autoPopulateEndFields = (Store<AppState> store) {
  final state = store.state.editor;
  final endBook = state.endBook < state.startBook ? state.startBook : state.endBook;
  var endChapter = state.endChapter;
  var endVerse = state.endVerse;
  if (endBook == state.startBook && endChapter < state.startChapter) {
    endChapter = state.startChapter;
  }
  if (endBook == state.startBook && endChapter == state.startChapter && endVerse <= state.endVerse) {
    final match = state.versesNumRefs.where((v) => v.isSameRef(endBook, endChapter)).toList();
    endVerse = match.length > 0 ? match[0].versesNum : state.startVerse;
  }
  store.dispatch(UpdateEditorState(
    state.copyWith(
      endBook: endBook,
      endChapter: endChapter,
      endVerse: endVerse,
    ),
  ));
};

ThunkAction<AppState> closeEditor = (Store<AppState> store) async {
  store.dispatch(goToHome);
  // side effects
};
