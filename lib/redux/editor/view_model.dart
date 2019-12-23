import 'package:bible_game/db/model.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/editor/actions.dart' as actions;
import 'package:bible_game/redux/editor/state.dart';
import 'package:bible_game/redux/themes/themes.dart';
import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';

class EditorViewModel {
  final List<BookModel> books;
  final EditorState state;
  final Function() closeHandler;
  final AppColorTheme theme;
  final Function(int) startBookChangeHandler;
  final Function(int) startChapterChangeHandler;
  final Function(int) startVerseChangeHandler;

  EditorViewModel({
    @required this.state,
    @required this.books,
    @required this.closeHandler,
    @required this.theme,
    @required this.startBookChangeHandler,
    @required this.startChapterChangeHandler,
    @required this.startVerseChangeHandler,
  });

  static EditorViewModel converter(Store<AppState> store) {
    return EditorViewModel(
      state: store.state.editor,
      theme: store.state.theme,
      books: store.state.game.books,
      closeHandler: () => store.dispatch(actions.closeEditor),
      startBookChangeHandler: (int bookId) => store.dispatch(actions.startBookChangeHandler(bookId)),
      startChapterChangeHandler: (int chapter) => store.dispatch(actions.startChapterChangeHandler(chapter)),
      startVerseChangeHandler: (int startVerse) => store.dispatch(actions.startVerseChangeHandler(startVerse)),
    );
  }
}