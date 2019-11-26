import 'package:bible_game/redux/quit_single_game_dialog/actions.dart';

bool quitSingleGameDialogReducer(bool state, action) {
  if (action is OpenQuitSingleGameDialog) {
    return true;
  } else if (action is CloseQuitSingleGameDialog) {
    return false;
  }
  return state;
}
