import 'package:bible_game/app/game_editor/actions/action_creators.dart';
import 'package:bible_game/app/game_editor/reducer/state.dart';

EditorState editorReducer(EditorState state, action) {
  if (action is UpdateEditorState) {
    return action.payload;
  }
  return state;
}
