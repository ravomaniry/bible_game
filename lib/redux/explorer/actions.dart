import 'package:bible_game/db/model.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/error/actions.dart';
import 'package:bible_game/redux/router/actions.dart';
import 'package:bible_game/redux/router/routes.dart';
import 'package:bible_game/statics.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:redux/redux.dart';

ThunkAction<AppState> loadBooks = (Store<AppState> store) async {
  try {
    final books = await store.state.dba.getBooks();
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
  final int bookId;
  ThunkAction<AppState> thunk;

  LoadVersesFor(this.bookId) {
    this.thunk = (Store<AppState> store) async {
      print("Loading verses for $bookId");
    };
  }
}

class ReceiveExplorerBooksList {
  final List<Books> payload;

  ReceiveExplorerBooksList(this.payload);
}
