import 'dart:ui' as ui;

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
  final List<Coordinate> confirmed;
  final List<Coordinate> hints;
  final Map<String, ui.Image> backgrounds;

  PathsViewModel({
    @required this.board,
    @required this.theme,
    @required this.paths,
    @required this.confirmed,
    @required this.hints,
    @required this.backgrounds,
  });
}

PathsViewModel pathConverter(Store<AppState> store) {
  return PathsViewModel(
    theme: store.state.theme,
    board: store.state.maze.board,
    paths: store.state.maze.paths,
    hints: store.state.maze.hints,
    confirmed: store.state.maze.confirmed,
    backgrounds: store.state.maze.backgrounds,
  );
}
