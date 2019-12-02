import 'package:bible_game/db/model.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/error/actions.dart';
import 'package:bible_game/redux/router/actions.dart';
import 'package:bible_game/redux/router/routes.dart';
import 'package:bible_game/statics.dart';
import 'package:bible_game/utils/retry.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

class ReceiveExplorerBooksList {
  final List<Books> payload;

  ReceiveExplorerBooksList(this.payload);
}

class GoToExplorerBooksList {}

class ExplorerSetActiveBook {
  Books payload;

  ExplorerSetActiveBook(this.payload);
}

class ExplorerReceiveVerses {
  final List<Verses> payload;

  ExplorerReceiveVerses(this.payload);
}

ThunkAction<AppState> loadBooks = (Store<AppState> store) async {
  try {
    final books = await retry<List<Books>>(() => store.state.dba.getBooks());
    if (books == null) {
      store.dispatch(ReceiveError(Errors.unknownDbError));
    } else {
      store.dispatch(ReceiveExplorerBooksList(books));
    }
  } catch (e) {
    store.dispatch(ReceiveError(Errors.unknownDbError));
    print(e);
  }
};

ThunkAction<AppState> goToExplorer = (Store<AppState> store) async {
  store.dispatch(GoToAction(Routes.explorer));
  store.dispatch(loadBooks);
};

class LoadVersesFor {
  final Books book;

  ThunkAction<AppState> thunk;

  LoadVersesFor(this.book) {
    this.thunk = (Store<AppState> store) async {
      store.dispatch(ExplorerSetActiveBook(this.book));
      try {
        final verses = await retry<List<Verses>>(() => store.state.dba.getVerses(book.id));
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
