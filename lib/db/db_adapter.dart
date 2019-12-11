import 'package:bible_game/db/model.dart';
import 'package:flutter/foundation.dart';

class DbAdapter {
  final BookModel bookModel;
  final VerseModel verseModel;
  final BibleGameModel db;
  final GameModel gameModel;

  DbAdapter({
    @required this.bookModel,
    @required this.verseModel,
    @required this.db,
    @required this.gameModel,
  });

  Future<bool> init() async {
    return db?.initializeDB() ?? false;
  }

  Future<List<GameModel>> get games => gameModel?.select()?.toList();

  Future<int> get booksCount => bookModel?.select(columnsToSelect: [BookModelFields.name.count()])?.toCount();

  Future<int> get versesCount => verseModel?.select(columnsToSelect: [VerseModelFields.id.count()])?.toCount();

  Future<List<BookModel>> get books => bookModel?.select()?.toList();

  Future<List<VerseModel>> getVerses(int bookId) {
    if (verseModel == null) {
      return null;
    }
    return verseModel.select().book.equals(bookId).toList();
  }

  Future<VerseModel> getSingleVerse(int bookId, int chapter, int verse) async {
    return verseModel
        ?.select()
        ?.book
        ?.equals(bookId)
        ?.and
        ?.chapter
        ?.equals(chapter)
        ?.and
        ?.verse
        ?.equals(verse)
        ?.toSingle();
  }

  Future<BookModel> getBookById(int bookId) async {
    return this.bookModel?.getById(bookId);
  }
}
