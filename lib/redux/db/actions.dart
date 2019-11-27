import 'package:redux/redux.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:redux_thunk/redux_thunk.dart';

class UpdateDbState {
  final bool payload;

  UpdateDbState(this.payload);
}

final ThunkAction<AppState> initDb = (Store<AppState> store) {
  if (!store.state.dbIsReady) {
    store.dispatch(UpdateDbState(true));
  }
};
