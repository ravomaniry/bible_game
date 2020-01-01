import 'package:bible_game/app/error/actions.dart';
import 'package:bible_game/app/error/state.dart';

ErrorState errorReducer(ErrorState state, action) {
  if (action is ReceiveError) {
    return action.payload;
  } else if (action is DismissError) {
    return null;
  }
  return state;
}
