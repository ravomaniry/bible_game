import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:flutter/widgets.dart';
import 'package:redux/redux.dart';

class AnimationsViewModel {
  final List<Coordinate> newlyRevealed;
  final Board board;

  AnimationsViewModel({
    @required this.board,
    @required this.newlyRevealed,
  });

  static AnimationsViewModel converter(Store<AppState> store) => AnimationsViewModel(
        board: store.state.maze.board,
        newlyRevealed: store.state.maze.newlyRevealed,
      );
}
