import 'package:bible_game/components/explorer/explorer.dart';
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
    return _RouterBuilder(viewModel.route, viewModel.gameIsResolved);
  }
}

class _RouterBuilder extends StatelessWidget {
  final Routes _route;
  final bool _gameIsResolved;

  _RouterBuilder(this._route, this._gameIsResolved);

  Widget build(BuildContext context) {
    if (_route == Routes.home) {
      return Home();
    } else if (_route == Routes.explorer) {
      return Explorer();
    } else {
      if (_gameIsResolved) {
        return Solution();
      } else if (_route == Routes.wordsInWord) {
        return WordsInWord();
      }
    }
    return Loader();
  }
}
