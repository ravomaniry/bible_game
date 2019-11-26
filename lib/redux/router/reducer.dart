import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/router/actions.dart';
import 'package:bible_game/redux/router/routes.dart';
import 'package:redux/redux.dart';

Routes routerReducer(Routes state, action) {
  if (action is GoToAction) {
    return action.payload;
  }
  return state;
}

void handleBackBtnPress(Store<AppState> store) {
  final handler = (bool yes) {
    if (store.state.route == Routes.home) {
      return false;
    } else {
      store.dispatch(goToHome);
      return true;
    }
  };
  BackButtonInterceptor.add(handler, name: "back_btn_handler");
}

void disposeBackBtnHandler() {
  BackButtonInterceptor.removeByName("back_btn_handler");
}
