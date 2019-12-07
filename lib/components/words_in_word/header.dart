import 'package:bible_game/redux/words_in_word/view_model.dart';
import 'package:flutter/cupertino.dart';

class Header extends StatelessWidget {
  final WordsInWordViewModel _viewModel;

  Header(this._viewModel);

  String get content {
    final state = _viewModel.wordsInWord;
    if (state.verse == null) {
      return "Words in word";
    }
    return "${state.verse.book} ${state.verse.chapter}: ${state.verse.verse}";
  }

  @override
  Widget build(BuildContext context) {
    return Text(content);
  }
}
