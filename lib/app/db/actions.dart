import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/db/state.dart';
import 'package:bible_game/app/error/actions.dart';
import 'package:bible_game/app/game/actions/init.dart';
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
    print("$count verses found");
    if (count == null) {
      dispatch(ReceiveError(Errors.unknownDbError()));
    } else if (count < 30000) {
      await dba.resetVerses();
      final source = await retry<String>(() => assetBundle.loadString("assets/db/verses.txt"));
      var verses = List<VerseModel>();
      final lines = source.split("\n");
      final words = lines[0].split(" ");
      final linesNum = lines.length;
      for (var i = 1; i < linesNum; i++) {
        if (lines[i].isNotEmpty) {
          verses.add(parseVerse(lines[i], words));
          if (verses.length == 100) {
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

VerseModel parseVerse(String line, List<String> words) {
  var text = "";
  final bookIdStr = _getFirstWord(line);
  line = line.substring(bookIdStr.length + 1);
  final chapterStr = _getFirstWord(line);
  line = line.substring(chapterStr.length + 1);
  final verseStr = _getFirstWord(line);
  line = line.substring(verseStr.length + 1);
  for (var i = 0, max = line.length; i < max; i++) {
    final char = line[i];
    if (char == "_") {
      final num = _getWordIndex(line, i + 1);
      text += words[int.parse(num, radix: 36)];
      i += num.length;
    } else {
      text += char;
    }
  }

  return VerseModel(
    book: int.parse(bookIdStr, radix: 10),
    chapter: int.parse(chapterStr, radix: 10),
    verse: int.parse(verseStr, radix: 10),
    text: text,
  );
}

String _getFirstWord(String value) {
  return value.substring(0, value.indexOf(" "));
}

final _numRegex = RegExp("[a-z0-9]+", caseSensitive: false);

String _getWordIndex(String line, int start) {
  var base36 = "";
  for (var i = start; i < line.length && _numRegex.hasMatch(line[i]); i++) {
    base36 += line[i];
  }
  return base36;
}
