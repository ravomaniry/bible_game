import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/router/routes.dart';
import 'package:redux_thunk/redux_thunk.dart';

class OpenQuitSingleGameDialog {}

class CloseQuitSingleGameDialog {}

ThunkAction<AppState> handleBackButtonPress() {
  return (store) {
    final gameRoutes = [Routes.maze, Routes.wordsInWord, Routes.anagram];
    if (gameRoutes.contains(store.state.route)) {
      if (store.state.quitSingleGameDialog) {
        store.dispatch(CloseQuitSingleGameDialog());
      } else {
        store.dispatch(OpenQuitSingleGameDialog());
      }
    }
  };
}
