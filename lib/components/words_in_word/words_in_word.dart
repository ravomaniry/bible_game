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
      appBar: AppBar(title: Text("Words in word")),
      body: _body(context, viewModel),
    );
  }

  Widget _body(BuildContext context, WordsInWordViewModel viewModel) {
    if (viewModel.verse == null) {
      return Text("Loading...");
    }
    return Center(
      child: ListView(
        children: viewModel.verse.words.map((w) => Text(w.value)).toList(),
      ),
    );
  }
}
