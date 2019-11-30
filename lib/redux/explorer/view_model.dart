import 'package:bible_game/redux/explorer/actions.dart';
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
      loadVerses: (Books book) => store.dispatch(LoadVersesFor(book).thunk),
      goToBooksList: () => store.dispatch(ExplorerSetActiveBook(null)),
    );
  }
}