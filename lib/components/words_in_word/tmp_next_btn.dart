import 'package:bible_game/redux/words_in_word/view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TempNextSection extends StatelessWidget {
  final WordsInWordViewModel _viewModel;

  TempNextSection(this._viewModel);

  @override
  Widget build(BuildContext context) {
    if (_viewModel.wordsToFind.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_viewModel.verse.text),
          Container(
            alignment: Alignment.centerRight,
            child: Text(
              "${_viewModel.verse.book} ${_viewModel.verse.chapter}: ${_viewModel.verse.verse}",
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
