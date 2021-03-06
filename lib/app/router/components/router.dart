import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/splash_screen/splash_screen.dart';
import 'package:bible_game/app/explorer/components/explorer.dart';
import 'package:bible_game/app/congrat/congratulation.dart';
import 'package:bible_game/app/game/components/home.dart';
import 'package:bible_game/app/game/components/solution.dart';
import 'package:bible_game/app/game_editor/components/editor.dart';
import 'package:bible_game/app/help/components/help.dart';
import 'package:bible_game/app/router/routes.dart';
import 'package:bible_game/app/router/view_model.dart';
import 'package:bible_game/games/anagram/components/anagram.dart';
import 'package:bible_game/games/maze/components/maze.dart';
import 'package:bible_game/games/words_in_word/components/words_in_word.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class Router extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, RouterViewModel>(
      converter: RouterViewModel.converter,
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, RouterViewModel viewModel) {
    return _RouterBuilder(
      route: viewModel.route,
      gameIsResolved: viewModel.gameIsResolved,
      activeGameIsCompleted: viewModel.activeGameIsCompleted,
    );
  }
}

class _RouterBuilder extends StatelessWidget {
  final Routes route;
  final bool gameIsResolved;
  final bool activeGameIsCompleted;

  _RouterBuilder({
    this.route,
    this.gameIsResolved,
    this.activeGameIsCompleted,
  });

  Widget build(BuildContext context) {
    switch (route) {
      case Routes.home:
        return Home();
      case Routes.explorer:
        return Explorer();
      case Routes.gameEditor:
        return GameEditor();
      case Routes.help:
        return Help();
      default:
        break;
    }
    if (activeGameIsCompleted) {
      return Congratulations();
    } else if (gameIsResolved) {
      return Solution();
    }
    switch (route) {
      case Routes.wordsInWord:
        return WordsInWord();
      case Routes.anagram:
        return Anagram();
      case Routes.maze:
        return Maze();
      default:
        return SplashScreen();
    }
  }
}
