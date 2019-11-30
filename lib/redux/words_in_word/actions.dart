import 'dart:async';
import 'package:bible_game/db/db_adapter.dart';
import 'package:bible_game/db/model.dart';
import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/error/actions.dart';
import 'package:bible_game/redux/router/actions.dart';
import 'package:bible_game/redux/router/routes.dart';
import 'package:bible_game/redux/words_in_word/cells_action.dart';
import 'package:bible_game/redux/words_in_word/state.dart';
import 'package:bible_game/statics.dart';
import 'package:bible_game/utils/retry.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:redux/redux.dart';

class SubmitWordsInWordResponse {}

class CancelWordsInWordResponse {}

class ResetWordsInWordVerse {}

class UpdateWordsInWordState {
  final WordsInWordState payload;

  UpdateWordsInWordState(this.payload);
}

class SelectWordsInWordChar {
  final Char payload;

  SelectWordsInWordChar(this.payload);
}

UpdateWordsInWordState receiveVerse(BibleVerse verse, WordsInWordState state) {
  return UpdateWordsInWordState(state.copyWith(verse: verse, wordsToFind: verse.words, resolvedWords: []));
}

final ThunkAction<AppState> goToWordsInWord = (Store<AppState> store) async {
  store.dispatch(GoToAction(Routes.wordsInWord));
  store.dispatch(UpdateWordsInWordState(WordsInWordState(
    verse: null,
    cells: [],
    slots: [],
    proposition: [],
    wordsToFind: [],
    resolvedWords: [],
  )));
  store.dispatch(loadWordsInWordNextVerse);
};

ThunkAction<AppState> loadWordsInWordNextVerse = (Store<AppState> store) async {
  store.dispatch(ResetWordsInWordVerse());
  final dba = store.state.dba;
  var bookId = 1;
  var chaptersNum = 1;
  var verseNum = 0;
  String bookName = "";
  int currentBookId = 0;
  final currentVerse = store.state.wordsInWord.verse;

  if (store.state.wordsInWord.verse != null) {
    bookId = currentVerse.bookId;
    chaptersNum = currentVerse.chapter;
    verseNum = currentVerse.verse;
    bookName = currentVerse.book;
    currentBookId = currentVerse.bookId;
  }

  try {
    final verse = await retry<Verses>(() => _getNextVerse(bookId, chaptersNum, verseNum, dba));
    if (verse != null && currentBookId != verse.book) {
      final book = await retry<Books>(() => dba.getBookById(verse.book));
      if (book != null) {
        bookName = book.name;
      }
    }
    if (verse == null || bookName == "") {
      store.dispatch(ReceiveError(Errors.unknownDbError));
    } else {
      final bibleVerse = BibleVerse.fromModel(verse, bookName);
      store.dispatch(receiveVerse(bibleVerse, store.state.wordsInWord));
      store.dispatch(recomputeCells);
    }
  } catch (e) {
    print(e);
    store.dispatch(ReceiveError(Errors.unknownDbError));
  }
};

Future<Verses> _getNextVerse(int bookId, int chapterNum, int verseNum, DbAdapter dba) async {
  var next = await dba.getSingleVerse(bookId, chapterNum, verseNum + 1);
  if (next != null) {
    return next;
  }
  next = await dba.getSingleVerse(bookId, chapterNum + 1, 1);
  if (next != null) {
    return next;
  }
  final booksNum = await dba.getBooksCount();
  if (bookId < booksNum) {
    return dba.getSingleVerse(bookId + 1, 1, 1);
  } else {
    return (Completer<Verses>()..completeError(null)).future;
  }
}
