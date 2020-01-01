import 'package:bible_game/app/theme/actions.dart';
import 'package:bible_game/app/theme/themes.dart';

AppColorTheme themeReducer(AppColorTheme state, action) {
  if (action is UpdateTheme) {
    return action.payload;
  }
  return state;
}
