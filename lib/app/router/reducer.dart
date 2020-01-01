import 'package:bible_game/app/router/actions.dart';
import 'package:bible_game/app/router/routes.dart';

Routes routerReducer(Routes state, action) {
  if (action is GoToAction) {
    return action.payload;
  }
  return state;
}
