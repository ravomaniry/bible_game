import 'package:bible_game/redux/words_in_word/view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(200, 191, 118, 41),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(100, 0, 0, 0),
            blurRadius: 0,
            offset: Offset(0, 2),
          )
        ],
      ),
      padding: EdgeInsets.only(top: 6, bottom: 6, left: 5, right: 5),
      margin: EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Text(content),
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Container(
            child: Text("${_viewModel.inventory.money} Ar."),
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
