import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';

class PathsViewModel {
  final AppColorTheme theme;
  final Board board;
  final List<List<Coordinate>> paths;

  PathsViewModel({
    @required this.board,
    @required this.theme,
    @required this.paths,
  });
}

PathsViewModel pathConverter(Store<AppState> store) {
  return PathsViewModel(
    theme: store.state.theme,
    board: store.state.maze.board,
    paths: store.state.maze.paths,
  );
}
