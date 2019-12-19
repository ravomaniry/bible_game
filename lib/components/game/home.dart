import 'package:bible_game/components/game/editor.dart';
import 'package:bible_game/components/game/games_list/index.dart';
import 'package:bible_game/components/game/header.dart';
import 'package:bible_game/components/loader.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/game/view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, GameViewModel>(
      key: Key("home"),
      builder: _builder,
      converter: GameViewModel.converter,
    );
  }

  Widget _builder(BuildContext context, GameViewModel viewModel) {
    if (viewModel.isReady) {
      return Scaffold(
        body: Container(
          padding: EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: viewModel.theme.primaryDark,
          ),
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  HomeHeader(viewModel),
                  GamesList(),
                ],
              ),
              GameEditor(),
            ],
          ),
        ),
      );
    }
    return Loader();
  }
}
