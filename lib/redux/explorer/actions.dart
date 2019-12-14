import 'package:bible_game/db/model.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/error/actions.dart';
import 'package:bible_game/redux/router/actions.dart';
import 'package:bible_game/redux/router/routes.dart';
import 'package:bible_game/statics/texts.dart';
import 'package:bible_game/utils/retry.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

class GoToExplorerBooksList {}

class ExplorerSetActiveBook {
  BookModel payload;

  ExplorerSetActiveBook(this.payload);
}

class ExplorerReceiveVerses {
  final List<VerseModel> payload;

  ExplorerReceiveVerses(this.payload);
}

ThunkAction<AppState> goToExplorer = (Store<AppState> store) async {
  store.dispatch(GoToAction(Routes.explorer));
};

class LoadVersesFor {
  final BookModel book;

  ThunkAction<AppState> thunk;

  LoadVersesFor(this.book) {
    this.thunk = (Store<AppState> store) async {
      store.dispatch(ExplorerSetActiveBook(this.book));
      try {
        final verses = await retry<List<VerseModel>>(() => store.state.dba.getVerses(book.id));
        if (verses == null) {
          store.dispatch(ReceiveError(Errors.unknownDbError));
        } else {
          store.dispatch(ExplorerReceiveVerses(verses));
        }
      } catch (e) {
        print(e);
        store.dispatch(ReceiveError(Errors.unknownDbError));
      }
    };
  }
}
