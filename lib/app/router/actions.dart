import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/confirm_quit_dialog/actions.dart' as dialog;
import 'package:bible_game/app/explorer/actions.dart' as explorer;
import 'package:bible_game/app/game/actions/init.dart' as game;
import 'package:bible_game/app/game_editor/actions/actions.dart' as editor;
import 'package:bible_game/app/help/actions/init.dart' as help;
import 'package:bible_game/app/inventory/actions/actions.dart' as inventory;
import 'package:bible_game/app/router/routes.dart';
import 'package:redux/redux.dart';

class GoToAction {
  final Routes payload;

  GoToAction(this.payload);
}

GoToAction goToHome() => GoToAction(Routes.home);

void handleBackBtnPress(Store<AppState> store) {
  final bool Function(bool) handler = (_) {
    final shouldHandle = _shouldHandleButtonPress(store.state);
    if (shouldHandle) {
      store.dispatch(inventory.handleBackButtonPress());
      store.dispatch(game.handleBackButtonPress());
      store.dispatch(editor.handleBackButtonPress());
      store.dispatch(explorer.handleBackButtonPress());
      store.dispatch(help.handleBackButtonPress());
      store.dispatch(dialog.handleBackButtonPress());
    }
    return shouldHandle;
  };
  BackButtonInterceptor.add(handler, name: "back_btn_handler");
}

bool _shouldHandleButtonPress(AppState state) {
  return state.route == Routes.anagram ||
      state.route == Routes.wordsInWord ||
      state.route == Routes.maze ||
      state.route == Routes.help ||
      state.route == Routes.explorer ||
      state.route == Routes.gameEditor ||
      state.game.inventory.isOpen ||
      state.game.isResolved;
}

void disposeBackBtnHandler() {
  BackButtonInterceptor.removeByName("back_btn_handler");
}
