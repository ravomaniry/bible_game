import 'package:bible_game/db/model.dart';
import 'package:bible_game/redux/error/actions.dart';
import 'package:bible_game/statics/texts.dart';
import 'package:bible_game/utils/retry.dart';
import 'package:redux/redux.dart';
import 'package:bible_game/models/game.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:redux_thunk/redux_thunk.dart';

class ReceiveGamesList {
  final List<GameModelWrapper> payload;

  ReceiveGamesList(this.payload);
}

class ReceiveBooksList {
  final List<BookModel> payload;

  ReceiveBooksList(this.payload);
}

class ToggleGamesEditorDialog {}

ThunkAction<AppState> initializeGames = (Store<AppState> store) async {
  final dba = store.state.dba;
  try {
    final books = await dba.books;
    final games = await retry(() => dba.games);
    if (games == null || books == null) {
      store.dispatch(ReceiveError(Errors.unknownDbError));
    } else {
      final gamesList = games.map((model) => GameModelWrapper.fromModel(model, books)).toList();
      store.dispatch(ReceiveBooksList(books));
      store.dispatch(ReceiveGamesList(gamesList));
    }
  } catch (e) {
    store.dispatch(ReceiveError(Errors.unknownDbError));
    print(e);
  }
};
