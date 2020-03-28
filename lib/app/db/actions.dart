import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/db/extract_verse.dart';
import 'package:bible_game/app/db/state.dart';
import 'package:bible_game/app/error/actions.dart';
import 'package:bible_game/app/game/actions/init.dart';
import 'package:bible_game/app/help/actions/init.dart';
import 'package:bible_game/db/db_adapter.dart';
import 'package:bible_game/db/model.dart';
import 'package:bible_game/statics/texts.dart';
import 'package:bible_game/utils/retry.dart';
import 'package:flutter/services.dart';
import 'package:redux_thunk/redux_thunk.dart';

class UpdateDbState {
  final DbState payload;

  UpdateDbState(this.payload);
}

ThunkAction<AppState> initDb() {
  return (store) async {
    if (!store.state.dbState.isReady) {
      final dba = store.state.dba;
      final isReady = await dba.init();
      if (isReady) {
        await checkAndUpdateBooks(dba, store.state.assetBundle, store.dispatch);
        await checkAndUpdateVerses(dba, store.state.assetBundle, store.dispatch);
        await initializeGames(dba, store.dispatch);
        store.dispatch(UpdateDbState(DbState(
          isReady: true,
          status: 100,
        )));
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
      final source = await retry<String>(() => assetBundle.loadString("assets/db/books.json"));
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
    } else if (count < 30000) {
      dispatch(goToHelp());
      await dba.resetVerses();
      final lines = await loadVerses(assetBundle);
      final linesNum = lines.length;
      final batchSize = 500;
      var verses = List<VerseModel>();
      for (var i = 0; i < linesNum; i++) {
        if (lines[i].isNotEmpty) {
          verses.add(parseVerse(lines[i]));
          if (verses.length == batchSize) {
            await retry(() => dba.verseModel.saveAll(verses));
            verses = [];
            dispatch(UpdateDbState(DbState(isReady: false, status: i / linesNum)));
          }
        }
      }
      if (verses.isNotEmpty) {
        await retry(() => dba.verseModel.saveAll(verses));
      }
    }
  } catch (e) {
    dispatch(ReceiveError(Errors.unknownDbError()));
    print("%%%%%%%%%%%% Error in checkAndUpdateVerses %%%%%%%%%%%%%");
    print(e);
  }
}

VerseModel parseVerse(String line) {
  final bookIdStr = _getNthWord(line, 0);
  final chapterStr = _getNthWord(line, 1);
  final verseStr = _getNthWord(line, 2);
  final text = line.substring(bookIdStr.length + chapterStr.length + verseStr.length + 3);
  return VerseModel(
    book: int.parse(bookIdStr, radix: 10),
    chapter: int.parse(chapterStr, radix: 10),
    verse: int.parse(verseStr, radix: 10),
    text: text,
  );
}

String _getNthWord(String value, int n) {
  var index = 0;
  for (var i = 0, length = value.length; i < length; i++) {
    if (value[i] == " ") {
      index++;
    } else {
      if (index == n) {
        return value.substring(i, value.indexOf(" ", i));
      }
    }
  }
  return "";
}
