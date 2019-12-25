import 'package:bible_game/db/model.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/editor/state.dart';
import 'package:bible_game/redux/explorer/actions.dart' as actions;
import 'package:bible_game/redux/explorer/state.dart';
import 'package:bible_game/redux/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';

class ExplorerViewModel {
  final List<BookModel> books;
  final ExplorerState state;
  final AppColorTheme theme;
  final Function() submitHandler;
  final Function() resetHandler;
  final Function(int) bookChangeHandler;
  final Function(int) chapterChangeHandler;
  final Function(int) verseChangeHandler;
  final List<VersesNumRef> versesNumRef;

  ExplorerViewModel({
    @required this.theme,
    @required this.books,
    @required this.state,
    @required this.submitHandler,
    @required this.bookChangeHandler,
    @required this.chapterChangeHandler,
    @required this.verseChangeHandler,
    @required this.resetHandler,
    @required this.versesNumRef,
  });

  static ExplorerViewModel converter(Store<AppState> store) {
    return ExplorerViewModel(
      theme: store.state.theme,
      books: store.state.game.books,
      state: store.state.explorer,
      versesNumRef: store.state.editor.versesNumRefs,
      bookChangeHandler: (int bookId) => store.dispatch(actions.bookChangeHandler(bookId)),
      chapterChangeHandler: (int chapter) => store.dispatch(actions.chapterChangeHandler(chapter)),
      verseChangeHandler: (int verse) => store.dispatch(actions.verseChangeHandler(verse)),
      submitHandler: () => store.dispatch(actions.submitHandler()),
      resetHandler: () => store.dispatch(actions.resetExplorer()),
    );
  }
}
