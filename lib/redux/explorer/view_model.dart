import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/redux/explorer/actions.dart';
import 'package:bible_game/redux/router/actions.dart';
import 'package:bible_game/redux/router/routes.dart';
import 'package:bible_game/redux/words_in_word/actions.dart';
import 'package:bible_game/redux/words_in_word/state.dart';
import 'package:redux/redux.dart';
import 'package:bible_game/db/model.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:flutter/material.dart';

class ExplorerViewModel {
  final List<Books> books;
  final Books activeBook;
  final List<Verses> verses;
  final Function(Books) loadVerses;
  final Function() goToBooksList;

  ExplorerViewModel({
    @required this.books,
    @required this.activeBook,
    @required this.verses,
    @required this.loadVerses,
    @required this.goToBooksList,
  });

  static ExplorerViewModel converter(Store<AppState> store) {
    return ExplorerViewModel(
      books: store.state.explorer.books,
      verses: store.state.explorer.verses,
      activeBook: store.state.explorer.activeBook,
      loadVerses: (Books book) {
        // store.dispatch(LoadVersesFor(book).thunk);
        // This is temporary code to redirect to the words in word section
        store.dispatch(UpdateWordsInWordState(
          WordsInWordState.emptyState().copyWith(
            verse: BibleVerse.fromModel(Verses(id: 1, book: book.id, chapter: 1, verse: 1, text: ""), book.name),
          ),
        ));
        store.dispatch(GoToAction(Routes.wordsInWord));
        store.dispatch(tempWordsInWordNext);
      },
      goToBooksList: () => store.dispatch(ExplorerSetActiveBook(null)),
    );
  }
}
