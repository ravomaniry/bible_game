import 'package:bible_game/redux/words_in_word/view_model.dart';
import 'package:flutter/cupertino.dart';

class Header extends StatelessWidget {
  final WordsInWordViewModel _viewModel;

  Header(this._viewModel);

  String get content {
    if (_viewModel.verse == null) {
      return "Words in word";
    }
    return "${_viewModel.verse.book} ${_viewModel.verse.chapter}: ${_viewModel.verse.verse}";
  }

  @override
  Widget build(BuildContext context) {
    return Text(content);
  }
}
