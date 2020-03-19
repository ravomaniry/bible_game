import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/confirm_quit_dialog/actions.dart';
import 'package:bible_game/app/explorer/actions.dart';
import 'package:bible_game/app/game/actions/lists_handler.dart';
import 'package:bible_game/app/inventory/actions/actions.dart';
import 'package:bible_game/app/router/routes.dart';
import 'package:redux/redux.dart';

class GoToAction {
  final Routes payload;

  GoToAction(this.payload);
}

GoToAction goToHome() => GoToAction(Routes.home);

void handleBackBtnPress(Store<AppState> store) {
  final bool Function(bool) handler = (bool yes) {
    if (store.state.game.inventory.isOpen) {
      store.dispatch(CloseInventoryDialog());
      store.dispatch(goToHome());
      return true;
    } else if (store.state.game.isResolved) {
      store.dispatch(saveActiveGame());
      store.dispatch(goToHome());
      return true;
    } else if (store.state.route == Routes.home) {
      return false;
    } else if (store.state.route == Routes.gameEditor) {
      store.dispatch(goToHome());
      return true;
    } else if (store.state.route == Routes.explorer) {
      if (store.state.explorer.submitted) {
        store.dispatch(resetExplorer());
      } else {
        store.dispatch(goToHome());
      }
      return true;
    } else if (store.state.route == Routes.help) {
      store.dispatch(goToHome());
      return true;
    } else {
      if (store.state.quitSingleGameDialog) {
        store.dispatch(CloseQuitSingleGameDialog());
      } else {
        store.dispatch(OpenQuitSingleGameDialog());
      }
      return true;
    }
  };
  BackButtonInterceptor.add(handler, name: "back_btn_handler");
}

void disposeBackBtnHandler() {
  BackButtonInterceptor.removeByName("back_btn_handler");
}
