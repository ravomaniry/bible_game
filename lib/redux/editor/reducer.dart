import 'package:bible_game/redux/editor/actions.dart';
import 'package:bible_game/redux/editor/state.dart';

EditorState editorReducer(EditorState state, action) {
  if (action is UpdateEditorState) {
    return action.payload;
  }
  return state;
}
