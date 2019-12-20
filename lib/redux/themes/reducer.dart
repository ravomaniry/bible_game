import 'package:bible_game/redux/themes/actions.dart';
import 'package:bible_game/redux/themes/themes.dart';

AppColorTheme themeReducer(AppColorTheme state, action) {
  if (action is UpdateTheme) {
    return action.payload;
  }
  return state;
}
