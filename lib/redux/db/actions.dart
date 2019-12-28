import 'package:bible_game/db/db_adapter.dart';
import 'package:bible_game/db/model.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/error/actions.dart';
import 'package:bible_game/redux/game/init.dart';
import 'package:bible_game/statics/texts.dart';
import 'package:bible_game/utils/retry.dart';
import 'package:flutter/services.dart';
import 'package:redux_thunk/redux_thunk.dart';

class UpdateDbState {
  final bool payload;

  UpdateDbState(this.payload);
}

ThunkAction<AppState> initDb() {
  return (store) async {
    if (!store.state.dbIsReady) {
      final dba = store.state.dba;
      final isReady = await dba.init();
      if (isReady) {
        await checkAndUpdateBooks(dba, store.state.assetBundle, store.dispatch);
        await checkAndUpdateVerses(dba, store.state.assetBundle, store.dispatch);
        await initializeGames(dba, store.dispatch);
        store.dispatch(UpdateDbState(true));
      } else {
        store.dispatch(ReceiveError(Errors.dbNotReady));
      }
    }
  };
}

Future checkAndUpdateBooks(DbAdapter dba, AssetBundle assetBundle, Function dispatch) async {
  try {
    final count = await retry<int>(() => dba.booksCount);
    if (count == null) {
      dispatch(ReceiveError(Errors.unknownDbError()));
    } else if (count == 0) {
      final source = await retry<String>(() => assetBundle.loadString("assets/db/new_testament_books.json"));
      final books = await BookModel.fromJson(source);
      await retry(() => dba.bookModel.saveAll(books));
    }
  } catch (e) {
    dispatch(ReceiveError(Errors.unknownDbError()));
    print("%%%%%%%%%%%% Error in checkAndUpdateBooks %%%%%%%%%%%%%");
    print(e);
  }
}

Future checkAndUpdateVerses(DbAdapter dba, AssetBundle assetBundle, Function dispatch) async {
  try {
    final count = await retry<int>(() => dba.versesCount);
    if (count == null) {
      dispatch(ReceiveError(Errors.unknownDbError()));
    } else if (count == 0) {
      final source = await retry<String>(() => assetBundle.loadString("assets/db/new_testament_verses.json"));
      final verses = await VerseModel.fromJson(source);
      await retry(() => dba.verseModel.saveAll(verses));
    }
  } catch (e) {
    dispatch(ReceiveError(Errors.unknownDbError()));
    print("%%%%%%%%%%%% Error in checkAndUpdateVerses %%%%%%%%%%%%%");
    print(e);
  }
}
