import 'package:bible_game/redux/app_state.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

ThunkAction<AppState> playGreetingSfx = (Store<AppState> store) {
  store.state.sfx.playGreeting();
};

ThunkAction<AppState> playSuccessSfx(bool longMode) {
  return (Store<AppState> store) {
    if (longMode) {
      store.state.sfx.playLongSuccess();
    } else {
      store.state.sfx.playShortSuccess();
    }
  };
}

ThunkAction<AppState> playBonusSfx = (Store<AppState> store) {
  store.state.sfx.playBonus();
};
