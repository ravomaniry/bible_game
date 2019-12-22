import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/router/routes.dart';
import 'package:redux_thunk/redux_thunk.dart';

class GameMode {
  final Routes route;
  final ThunkAction<AppState> initAction;

  GameMode(this.route, this.initAction);
}
