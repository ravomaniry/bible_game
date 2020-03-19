import 'package:bible_game/app/help/actions/actions.dart';
import 'package:bible_game/app/help/state.dart';

HelpState helpReducer(action, HelpState state) {
  if (action is ReceiveHelp) {
    return HelpState(action.payload);
  }
  return state;
}
