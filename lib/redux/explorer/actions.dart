import 'package:bible_game/db/model.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/editor/actions.dart';
import 'package:bible_game/redux/error/actions.dart';
import 'package:bible_game/redux/explorer/state.dart';
import 'package:bible_game/redux/router/actions.dart';
import 'package:bible_game/redux/router/routes.dart';
import 'package:bible_game/statics/texts.dart';
import 'package:bible_game/utils/retry.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

class UpdateExplorerState {
  final ExplorerState payload;

  UpdateExplorerState(this.payload);
}

ThunkAction<AppState> goToExplorer() {
  return (Store<AppState> store) async {
    store.dispatch(GoToAction(Routes.explorer));
    loadVersesNum(1, 1, store);
  };
}

ThunkAction<AppState> resetExplorer() {
  return (store) {
    store.dispatch(UpdateExplorerState(store.state.explorer.reset()));
  };
}

ThunkAction<AppState> bookChangeHandler(int bookId) {
  return (store) {
    store.dispatch(UpdateExplorerState(store.state.explorer.copyWith(
      activeBook: bookId,
      activeChapter: 1,
      activeVerse: 1,
      verses: [],
      submitted: false,
    )));
    loadVersesNum(bookId, 1, store);
  };
}

ThunkAction<AppState> chapterChangeHandler(int chapter) {
  return (store) {
    final state = store.state.explorer;
    store.dispatch(UpdateExplorerState(state.copyWith(
      activeChapter: chapter,
      activeVerse: 1,
      verses: [],
      submitted: false,
    )));
    loadVersesNum(state.activeBook, chapter, store);
  };
}

ThunkAction<AppState> verseChangeHandler(int verse) {
  return (store) {
    store.dispatch(UpdateExplorerState(
      store.state.explorer.copyWith(
        activeVerse: verse,
        submitted: false,
      ),
    ));
  };
}

ThunkAction<AppState> submitHandler() {
  return (store) async {
    final state = store.state.explorer;
    store.dispatch(UpdateExplorerState(state.copyWith(submitted: true)));
    try {
      final verses = await retry<List<VerseModel>>(
        () => store.state.dba.getVerses(
          state.activeBook,
          chapter: state.activeChapter,
          verse: state.activeVerse,
        ),
      );
      if (verses == null) {
        store.dispatch(ReceiveError(Errors.unknownDbError()));
      } else {
        store.dispatch(UpdateExplorerState(store.state.explorer.copyWith(verses: verses)));
      }
    } catch (e) {
      print("%%%%%%%%%%%% error in submitHandler %%%%%%%%%%");
      print(e);
      store.dispatch(ReceiveError(Errors.unknownDbError()));
    }
  };
}
