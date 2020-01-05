import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:bible_game/games/maze/redux/state.dart';
import 'package:flutter/widgets.dart';
import 'package:redux/redux.dart';

class MazeViewModel {
  final MazeState state;
  final AppColorTheme theme;

  MazeViewModel({
    @required this.state,
    @required this.theme,
  });

  static MazeViewModel converter(Store<AppState> store) {
    return MazeViewModel(
      state: store.state.maze,
      theme: store.state.theme,
    );
  }
}
