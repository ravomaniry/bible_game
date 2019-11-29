import 'package:bible_game/redux/config/actions.dart';
import 'package:bible_game/redux/config/state.dart';

ConfigState configReducer(ConfigState state, action) {
  if (action is UpdateScreenWidth) {
    return state.copyWith(screenWidth: action.payload);
  }
  return state;
}
