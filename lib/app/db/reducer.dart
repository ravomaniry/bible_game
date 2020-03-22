import 'package:bible_game/app/db/actions.dart';
import 'package:bible_game/app/db/state.dart';

DbState dbReducer(DbState state, action) {
  if (action is UpdateDbState) {
    return action.payload;
  }
  return state;
}
