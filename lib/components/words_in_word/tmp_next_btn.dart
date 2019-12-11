import 'package:bible_game/redux/words_in_word/view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TempNextSection extends StatelessWidget {
  final WordsInWordViewModel _viewModel;

  TempNextSection(this._viewModel);

  @override
  Widget build(BuildContext context) {
    final state = _viewModel.wordsInWord;
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.fitWidth,
          image: AssetImage("assets/images/forest.jpg"),
        ),
      ),
      child: Column(
        children: <Widget>[
          Expanded(child: Divider()),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromARGB(200, 255, 255, 255),
            ),
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state.verse.text,
                  style: const TextStyle(fontSize: 16),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "${state.verse.book} ${state.verse.chapter}: ${state.verse.verse}",
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                RaisedButton(
                  onPressed: _viewModel.tempNextVerseHandler,
                  child: Text("Next"),
                )
              ],
            ),
          ),
          Expanded(child: Divider()),
        ],
      ),
    );
  }
}
