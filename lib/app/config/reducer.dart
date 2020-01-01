import 'package:bible_game/app/config/actions.dart';
import 'package:bible_game/app/config/state.dart';

ConfigState configReducer(ConfigState state, action) {
  if (action is UpdateScreenWidth) {
    return state.copyWith(screenWidth: action.payload);
  }
  return state;
}
