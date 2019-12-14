import 'dart:async';
import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/game.dart';
import 'package:bible_game/redux/error/actions.dart';
import 'package:bible_game/redux/game/actions.dart';
import 'package:bible_game/redux/game/lists_handler.dart';
import 'package:bible_game/redux/inventory/actions.dart';
import 'package:bible_game/redux/words_in_word/logics.dart';
import 'package:bible_game/statics/texts.dart';
import 'package:bible_game/utils/retry.dart';
import 'package:redux/redux.dart';
import 'package:bible_game/db/db_adapter.dart';
import 'package:bible_game/db/model.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:redux_thunk/redux_thunk.dart';

ThunkAction<AppState> saveGameAndLoadNextVerse = (Store<AppState> store) async {
  try {
    final game = store.state.game.list.firstWhere((g) => g.model.id == store.state.game.activeId);
    final nextVerse = await _getNextVerse(game, store.state.game.books, store.state.dba, store.dispatch);
    if (nextVerse != null) {
      final nextBookName = store.state.game.books.firstWhere((b) => b.id == nextVerse.book).name;
      final nextGame = game.copyWith(
        nextBook: nextVerse.book,
        nextChapter: nextVerse.chapter,
        nextVerse: nextVerse.verse,
        resolvedVersesCount: game.resolvedVersesCount + 1,
      );
      final nextList = getUpdatedGamesList(nextGame, store.state.game.list, store.state.game.activeId);
      store.dispatch(OpenInventoryDialog(false));
      store.dispatch(UpdateGameResolvedState(false));
      store.dispatch(UpdateGameVerse(BibleVerse.fromModel(nextVerse, nextBookName)));
      store.dispatch(initializeWordsInWordState);
      store.dispatch(ReceiveGamesList(nextList));
      store.dispatch(saveActiveGame);
    }
  } catch (e) {
    print("%%%%%%%%%% error in saveGameAndLoadNextVerse");
    print(e);
  }
};

ThunkAction<AppState> incrementResolvedVersesNum = (Store<AppState> store) {
  final game = store.state.game.list.firstWhere((g) => g.model.id == store.state.game.activeId);
  final nextGame = game.copyWith(resolvedVersesCount: game.resolvedVersesCount + 1);
  final nextList = getUpdatedGamesList(nextGame, store.state.game.list, store.state.game.activeId);
  store.dispatch(ReceiveGamesList(nextList));
};

Future<VerseModel> _getNextVerse(
  GameModelWrapper game,
  List<BookModel> books,
  DbAdapter dba,
  Function dispatch,
) async {
  final bookId = game.nextBook;
  final book = books.firstWhere((b) => b.id == bookId);

  if (game.isCompleted) {
    dispatch(UpdateGameCompletedState(true));
    dispatch(incrementResolvedVersesNum);
    return null;
  } else {
    try {
      var next = await retry(() => dba.getSingleVerse(bookId, game.nextChapter, game.nextVerse + 1));
      if (next != null) {
        return next;
      } else if (book.chapters > game.nextChapter) {
        return await retry(() => dba.getSingleVerse(bookId, game.nextChapter + 1, 1));
      } else if (bookId < game.model.endBook) {
        return await retry(() => dba.getSingleVerse(bookId + 1, 1, 1));
      }
    } catch (e) {
      dispatch(ReceiveError(Errors.unknownDbError));
      print("%%%%%%%%%% error in _getNextVerse");
      print(e);
    }
  }
  return null;
}
