import 'package:bible_game/app/game/components/in_game_header.dart';
import 'package:bible_game/app/components/splash_screen.dart';
import 'package:bible_game/games/words_in_word/components/controls.dart';
import 'package:bible_game/games/words_in_word/components/results.dart';
import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/games/words_in_word/view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class WordsInWord extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, WordsInWordViewModel>(
      key: Key("wordsInWord"),
      builder: _builder,
      converter: WordsInWordViewModel.converter,
    );
  }

  Widget _builder(BuildContext context, WordsInWordViewModel viewModel) {
    return WordsInWordBody(viewModel);
  }
}

class WordsInWordBody extends StatelessWidget {
  final WordsInWordViewModel _viewModel;

  WordsInWordBody(this._viewModel);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Key("gameScreen"),
      body: _body(),
    );
  }

  Widget _body() {
    if (_viewModel.inventory.isOpen) {
      return SizedBox.expand();
    } else if (_viewModel.verse == null) {
      return SplashScreen();
    } else {
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fitHeight,
            image: AssetImage(_viewModel.theme.background),
          ),
        ),
        child: Column(
          children: [
            InGameHeader(),
            WordsInWordResult(_viewModel),
            WordsInWordControls(_viewModel),
          ],
        ),
      );
    }
  }
}
