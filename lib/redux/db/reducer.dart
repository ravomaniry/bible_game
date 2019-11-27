import 'package:bible_game/redux/db/actions.dart';

bool dbReducer(bool state, action) {
  if (action is UpdateDbState) {
    return action.payload;
  }
  return state;
}
