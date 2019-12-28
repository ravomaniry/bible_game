import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/router/routes.dart';
import 'package:bible_game/redux/themes/themes.dart';
import 'package:redux_thunk/redux_thunk.dart';

class GameMode {
  final Routes route;
  final AppColorTheme theme;
  final ThunkAction<AppState> Function() initAction;

  GameMode(this.route, this.initAction, this.theme);
}
