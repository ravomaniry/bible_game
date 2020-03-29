import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/texts.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:bible_game/games/maze/redux/state.dart';
import 'package:flutter/widgets.dart';
import 'package:redux/redux.dart';

class BoardViewModel {
  final MazeState state;
  final AppColorTheme theme;
  final AppTexts texts;

  BoardViewModel({
    @required this.state,
    @required this.theme,
    @required this.texts,
  });

  static BoardViewModel converter(Store<AppState> store) {
    return BoardViewModel(
      state: store.state.maze,
      theme: store.state.theme,
      texts: store.state.texts,
    );
  }
}
