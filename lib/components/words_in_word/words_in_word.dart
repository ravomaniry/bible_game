import 'package:bible_game/components/loader.dart';
import 'package:bible_game/components/words_in_word/controls.dart';
import 'package:bible_game/components/game/in_game_header.dart';
import 'package:bible_game/components/words_in_word/results.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/words_in_word/view_model.dart';
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
    return Scaffold(
      body: _body(context, viewModel),
    );
  }

  Widget _body(BuildContext context, WordsInWordViewModel viewModel) {
    if (viewModel.inventory.isOpen) {
      return SizedBox.expand();
    } else if (viewModel.verse == null) {
      return Loader();
    } else {
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fitHeight,
            image: AssetImage(viewModel.theme.background),
          ),
        ),
        child: Column(
          children: [
            InGameHeader(),
            WordsInWordResult(viewModel),
            WordsInWordControls(viewModel),
          ],
        ),
      );
    }
  }
}
