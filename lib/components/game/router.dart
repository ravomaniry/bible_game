import 'package:bible_game/components/explorer/explorer.dart';
import 'package:bible_game/components/game/congratulation.dart';
import 'package:bible_game/components/game/home.dart';
import 'package:bible_game/components/game/solution.dart';
import 'package:bible_game/components/loader.dart';
import 'package:bible_game/components/words_in_word/words_in_word.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/router/routes.dart';
import 'package:bible_game/redux/router/view_model.dart';
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
    if (route == Routes.home) {
      return Home();
    } else if (route == Routes.explorer) {
      return Explorer();
    } else {
      if (activeGameIsCompleted) {
        return Congratulations();
      } else if (gameIsResolved) {
        return Solution();
      } else if (route == Routes.wordsInWord) {
        return WordsInWord();
      }
    }
    return Loader();
  }
}
