import 'package:bible_game/redux/words_in_word/view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TempNextSection extends StatelessWidget {
  final WordsInWordViewModel _viewModel;

  TempNextSection(this._viewModel);

  @override
  Widget build(BuildContext context) {
    final state = _viewModel.wordsInWord;

    if (state.wordsToFind.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(state.verse.text),
          Container(
            alignment: Alignment.centerRight,
            child: Text(
              "${state.verse.book} ${state.verse.chapter}: ${state.verse.verse}",
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          MaterialButton(
            onPressed: _viewModel.tempNextVerseHandler,
            child: Text("Next"),
          )
        ],
      );
    }
    return SizedBox.shrink();
  }
}
