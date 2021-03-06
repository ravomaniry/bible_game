import 'dart:async';

import 'package:bible_game/db/db_adapter.dart';
import 'package:bible_game/db/model.dart';
import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/game.dart';
import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/error/actions.dart';
import 'package:bible_game/app/game/actions/actions.dart';
import 'package:bible_game/app/game/actions/lists_handler.dart';
import 'package:bible_game/app/inventory/actions/actions.dart';
import 'package:bible_game/statics/texts.dart';
import 'package:bible_game/utils/retry.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

ThunkAction<AppState> saveGameAndLoadNextVerse() {
  return (Store<AppState> store) async {
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

        store.dispatch(_invalidateExpandedVerses());
        store.dispatch(OpenInventoryDialog(false));
        store.dispatch(UpdateGameResolvedState(false));
        store.dispatch(UpdateGameVerse(BibleVerse.fromModel(nextVerse, nextBookName)));
        store.dispatch(initializeRandomGame());
        store.dispatch(ReceiveGamesList(nextList));
        store.dispatch(saveActiveGame());
      }
    } catch (e) {
      print("%%%%%%%%%% error in saveGameAndLoadNextVerse");
      print(e);
      store.dispatch(ReceiveError(Errors.unknownDbError()));
    }
  };
}

ThunkAction<AppState> _incrementResolvedVersesNum() {
  return (Store<AppState> store) {
    final game = store.state.game.list.firstWhere((g) => g.model.id == store.state.game.activeId);
    final nextGame = game.copyWith(resolvedVersesCount: game.resolvedVersesCount + 1);
    final nextList = getUpdatedGamesList(nextGame, store.state.game.list, store.state.game.activeId);
    store.dispatch(ReceiveGamesList(nextList));
  };
}

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
    dispatch(_incrementResolvedVersesNum());
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
      dispatch(ReceiveError(Errors.unknownDbError()));
      print("%%%%%%%%%% error in _getNextVerse");
      print(e);
    }
  }
  return null;
}

ThunkAction<AppState> expandVerses() {
  return (store) async {
    try {
      final activeVerse = store.state.game.verse;
      final verses = await retry(() => store.state.dba.getChapterVersesUntil(
            activeVerse.bookId,
            activeVerse.chapter,
            activeVerse.verse,
          ));
      store.dispatch(UpdateGameState(
        store.state.game.copyWith(
          expandedVerses: verses.reversed.toList(),
        ),
      ));
    } catch (e) {
      print("%%%%%%%%%%% error in exoadVerses %%%%%%%%%%%%");
      print(e);
      store.dispatch(ReceiveError(Errors.unknownDbError()));
    }
  };
}

ThunkAction<AppState> _invalidateExpandedVerses() {
  return (store) {
    store.dispatch(UpdateGameState(store.state.game.copyWith(
      expandedVerses: [],
    )));
  };
}
