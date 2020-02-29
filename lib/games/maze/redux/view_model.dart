import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/games/maze/logic/logic.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:flutter/cupertino.dart';
import 'package:redux/redux.dart';

class MazeViewModel {
  final Function(List<Coordinate> cells) propose;

  MazeViewModel({
    @required this.propose,
  });

  static MazeViewModel converter(Store<AppState> store) {
    return MazeViewModel(
      propose: (cells) => store.dispatch(proposeMaze(cells)),
    );
  }
}
