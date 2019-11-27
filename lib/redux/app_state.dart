import 'package:bible_game/db/db_adapter.dart';
import 'package:bible_game/db/model.dart';
import 'package:bible_game/redux/calculator/state.dart';
import 'package:bible_game/redux/router/routes.dart';
import 'package:bible_game/redux/words_in_word/state.dart';
import 'package:flutter/cupertino.dart';

class AppState {
  Routes route;
  CalculatorState calculator;
  WordsInWordState wordsInWord;
  bool quitSingleGameDialog;
  final DbAdapter dba;
  final bool dbIsReady;

  AppState({
    this.route = Routes.home,
    this.calculator,
    this.wordsInWord,
    this.quitSingleGameDialog = false,
    this.dbIsReady = false,
    @required this.dba,
  });

  factory AppState.initialState() {
    return AppState(
      dba: DbAdapter(
        model: BibleGameModel(),
        books: Books(),
        verses: Verses(),
      ),
    );
  }
}
