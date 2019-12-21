import 'package:bible_game/components/game/editor.dart';
import 'package:bible_game/components/game/games_list/index.dart';
import 'package:bible_game/components/game/header.dart';
import 'package:bible_game/components/loader.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/game/view_model.dart';
import 'package:bible_game/redux/themes/themes.dart';
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
      return _HomeContainer(
        theme: viewModel.theme,
        children: <Widget>[
          Column(
            children: <Widget>[
              HomeHeader(viewModel),
              GamesList(),
            ],
          ),
          GameEditor(),
        ],
      );
    }
    return Loader();
  }
}

class _HomeContainer extends StatelessWidget {
  final List<Widget> children;
  final AppColorTheme theme;

  _HomeContainer({@required this.children, @required this.theme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(theme.background),
            fit: BoxFit.fill,
          ),
        ),
        child: Container(
          padding: EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [theme.neutral, Colors.transparent],
              stops: [0.05, 1],
            ),
          ),
          child: Stack(
            children: children,
          ),
        ),
      ),
    );
  }
}
