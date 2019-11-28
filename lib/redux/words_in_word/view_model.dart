import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/cell.dart';
import 'package:bible_game/models/words_in_word/Char.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/words_in_word/actions.dart';
import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';

class WordsInWordViewModel {
  final BibleVerse verse;
  final List<List<Cell>> cells;
  final List<WordsInWordChar> chars;
  final List<WordsInWordChar> selected;
  final Function(WordsInWordChar) selectHandler;
  final Function() submitHandler;
  final Function() cancelHandler;

  WordsInWordViewModel({
    @required this.verse,
    @required this.cells,
    @required this.chars,
    @required this.selected,
    @required this.selectHandler,
    @required this.submitHandler,
    @required this.cancelHandler,
  });

  static WordsInWordViewModel converter(Store<AppState> store) {
    return WordsInWordViewModel(
      verse: store.state.wordsInWord.verse,
      cells: store.state.wordsInWord.cells,
      chars: store.state.wordsInWord.chars,
      selected: store.state.wordsInWord.selected,
      selectHandler: (WordsInWordChar char) => store.dispatch(SelectWordsInWordChar(char)),
      submitHandler: () => store.dispatch(SubmitWordsInWordResponse()),
      cancelHandler: () => store.dispatch(CancelWordsInWordResponse()),
    );
  }
}
