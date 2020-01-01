import 'package:bible_game/app/db/actions.dart';

bool dbReducer(bool state, action) {
  if (action is UpdateDbState) {
    return action.payload;
  }
  return state;
}
