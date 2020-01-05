import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/game/components/in_game_header.dart';
import 'package:bible_game/games/maze/components/temp_board.dart';
import 'package:bible_game/games/maze/redux/view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class Maze extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, MazeViewModel>(
      key: Key("maze"),
      converter: MazeViewModel.converter,
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, MazeViewModel viewModel) {
    return MazeBody(viewModel);
  }
}

class MazeBody extends StatelessWidget {
  final MazeViewModel _viewModel;

  MazeBody(this._viewModel);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Key("gameScreen"),
      body: _body(),
    );
  }

  Widget _body() {
    return Column(
      children: [
        InGameHeader(),
        MazeBoard(
          wordsToFind: _viewModel.state.wordsToFind,
          board: _viewModel.state.board,
          theme: _viewModel.theme,
        ),
      ],
    );
  }
}
