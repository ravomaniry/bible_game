import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/router/routes.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:redux_thunk/redux_thunk.dart';

class GameMode {
  final Routes route;
  final AppColorTheme theme;
  final ThunkAction<AppState> Function() initAction;

  GameMode(this.route, this.initAction, this.theme);
}
