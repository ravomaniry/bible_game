import 'package:redux/redux.dart';
import 'package:bible_game/redux/router/routes.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/inventory/actions.dart';
import 'package:bible_game/redux/quit_single_game_dialog/actions.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

class GoToAction {
  final Routes payload;

  GoToAction(this.payload);
}

final goToHome = GoToAction(Routes.home);

void handleBackBtnPress(Store<AppState> store) {
  final bool Function(bool) handler = (bool yes) {
    if (store.state.inventory.isOpen) {
      store.dispatch(closeInventoryDialog);
      return true;
    } else if (store.state.route == Routes.home) {
      return false;
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
