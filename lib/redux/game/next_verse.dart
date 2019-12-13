import 'dart:async';
import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/redux/game/actions.dart';
import 'package:bible_game/redux/game/lists_handler.dart';
import 'package:bible_game/redux/inventory/actions.dart';
import 'package:bible_game/redux/words_in_word/logics.dart';
import 'package:redux/redux.dart';
import 'package:bible_game/db/db_adapter.dart';
import 'package:bible_game/db/model.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:redux_thunk/redux_thunk.dart';

ThunkAction<AppState> saveGameAndLoadNextVerse = (Store<AppState> store) async {
  store.dispatch(UpdateGameResolvedState(false));
  store.dispatch(OpenInventoryDialog(false));

  try {
    final game = store.state.game.list.firstWhere((g) => g.model.id == store.state.game.activeId);
    final nextVerse = await _getNextVerse(game.nextBook, game.nextChapter, game.nextVerse, store.state.dba);
    final nextBookName = store.state.game.books.firstWhere((b) => b.id == nextVerse.book).name;
    final nextGame = game.copyWith(
      nextBook: nextVerse.book,
      nextChapter: nextVerse.chapter,
      nextVerse: nextVerse.verse,
      resolvedVersesCount: game.resolvedVersesCount + 1,
    );
    store.dispatch(UpdateGameVerse(BibleVerse.fromModel(nextVerse, nextBookName)));
    store.dispatch(initializeWordsInWordState);
    final nextList = getUpdatedGamesList(nextGame, store.state.game.list, store.state.game.activeId);
    store.dispatch(ReceiveGamesList(nextList));
    store.dispatch(saveActiveGame);
  } catch (e) {
    print("%%%%%%%%%% error in saveGameAndLoadNextVerse");
    print(e);
  }
};

Future<VerseModel> _getNextVerse(int bookId, int chapterNum, int verseNum, DbAdapter dba) async {
  var next = await dba.getSingleVerse(bookId, chapterNum, verseNum + 1);
  if (next != null) {
    return next;
  }
  next = await dba.getSingleVerse(bookId, chapterNum + 1, 1);
  if (next != null) {
    return next;
  }
  final booksNum = await dba.booksCount;
  if (bookId < booksNum) {
    return dba.getSingleVerse(bookId + 1, 1, 1);
  } else {
    return (Completer<VerseModel>()..completeError(null)).future;
  }
}
