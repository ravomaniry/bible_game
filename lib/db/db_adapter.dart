import 'package:bible_game/db/model.dart';
import 'package:flutter/foundation.dart';

class DbAdapter {
  final BookModel books;
  final VerseModel verses;
  final BibleGameModel model;

  DbAdapter({
    @required this.books,
    @required this.verses,
    @required this.model,
  });

  Future<bool> init() async {
    return model?.initializeDB() ?? false;
  }

  Future<int> getBooksCount() => books?.select(columnsToSelect: [BookModelFields.name.count()])?.toCount();

  Future<int> getVersesCount() => verses?.select(columnsToSelect: [VerseModelFields.id.count()])?.toCount();

  Future<List<BookModel>> getBooks() => books?.select()?.toList();

  Future<List<VerseModel>> getVerses(int bookId) {
    if (verses == null) {
      return null;
    }
    return verses.select().book.equals(bookId).toList();
  }

  Future<VerseModel> getSingleVerse(int bookId, int chapter, int verse) async {
    return verses?.select()?.book?.equals(bookId)?.and?.chapter?.equals(chapter)?.and?.verse?.equals(verse)?.toSingle();
  }

  Future<BookModel> getBookById(int bookId) async {
    return this.books?.getById(bookId);
  }
}
