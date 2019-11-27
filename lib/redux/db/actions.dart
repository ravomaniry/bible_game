import 'package:bible_game/db/db_adapter.dart';
import 'package:bible_game/db/model.dart';
import 'package:bible_game/redux/error/actions.dart';
import 'package:bible_game/statics.dart';
import 'package:flutter/services.dart';
import 'package:redux/redux.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:redux_thunk/redux_thunk.dart';

class UpdateDbState {
  final bool payload;

  UpdateDbState(this.payload);
}

final ThunkAction<AppState> initDb = (Store<AppState> store) async {
  if (!store.state.dbIsReady) {
    final dba = store.state.dba;
    final isReady = await dba.init();
    if (isReady) {
      await checkAndUpdateBooks(dba, store.state.assetBundle, store.dispatch);
      await checkAndUpdateVerses(dba, store.state.assetBundle, store.dispatch);
      store.dispatch(UpdateDbState(true));
    } else {
      store.dispatch(ReceiveError(Errors.dbNotReady));
    }
  }
};

Future checkAndUpdateBooks(DbAdapter dba, AssetBundle assetBundle, Function dispatch) async {
  try {
    final count = await dba.getBooksCount();
    if (count == null) {
      dispatch(ReceiveError(Errors.unknownDbError));
    } else if (count == 0) {
      final source = await assetBundle.loadString("assets/db/new_testament_books.json");
      final books = await Books.fromJson(source);
      await dba.books.saveAll(books);
    }
  } catch (e) {
    dispatch(ReceiveError(Errors.unknownDbError));
    print(e);
  }
}

Future checkAndUpdateVerses(DbAdapter dba, AssetBundle assetBundle, Function dispatch) async {
  try {
    final count = await dba.getVersesCount();
    if (count == null) {
      dispatch(ReceiveError(Errors.unknownDbError));
    } else if (count == 0) {
      final source = await assetBundle.loadString("assets/db/new_testament_verses.json");
      final verses = await Verses.fromJson(source);
      await dba.verses.saveAll(verses);
    }
  } catch (e) {
    dispatch(ReceiveError(Errors.unknownDbError));
    print(e.toString());
  }
}
