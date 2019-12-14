import 'package:bible_game/db/model.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/explorer/actions.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';

class ExplorerViewModel {
  final List<BookModel> books;
  final BookModel activeBook;
  final List<VerseModel> verses;
  final Function(BookModel) loadVerses;
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
      books: store.state.game.books,
      verses: store.state.explorer.verses,
      activeBook: store.state.explorer.activeBook,
      loadVerses: (BookModel book) => store.dispatch(LoadVersesFor(book).thunk),
      goToBooksList: () => store.dispatch(ExplorerSetActiveBook(null)),
    );
  }
}
