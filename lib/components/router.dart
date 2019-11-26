import 'package:bible_game/components/calculator/calculator.dart';
import 'package:bible_game/components/home/home.dart';
import 'package:bible_game/components/loader.dart';
import 'package:bible_game/components/words_in_word/words_in_word.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/router/routes.dart';
import 'package:bible_game/redux/router/view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class Router extends StatelessWidget {
  Router({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, RouterViewModel>(
      converter: RouterViewModel.converter,
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, RouterViewModel viewModel) {
    switch (viewModel.route) {
      case Routes.home:
        return Home();
      case Routes.calculator:
        return viewModel.calculatorIsReady ? Calculator() : Loader();
      case Routes.wordsInWord:
        return viewModel.wordsInWordIsReady ? WordsInWord() : Loader();
      default:
        return Loader();
    }
  }
}
