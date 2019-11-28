import 'package:bible_game/db/model.dart';
import 'package:flutter/foundation.dart';

class DbAdapter {
  final Books books;
  final Verses verses;
  final BibleGameModel model;

  DbAdapter({
    @required this.books,
    @required this.verses,
    @required this.model,
  });

  Future<bool> init() async {
    return model?.initializeDB() ?? false;
  }

  Future<int> getBooksCount() => books?.select(columnsToSelect: [BooksFields.name.count()])?.toCount();

  Future<int> getVersesCount() => verses?.select(columnsToSelect: [VersesFields.id.count()])?.toCount();

  Future<List<Books>> getBooks() => books?.select()?.toList();

  Future<List<Verses>> getVerses(int bookId) {
    if (verses == null) {
      return null;
    }
    return verses.select().book.equals(bookId).toList();
  }

  Future<Verses> getSingleVerse(int bookId, int chapter, int verse) async {
    return verses?.select()?.book?.equals(bookId)?.and?.chapter?.equals(chapter)?.and?.verse?.equals(verse)?.toSingle();
  }

  Future<Books> getBookById(int bookId) async {
    return this.books?.getById(bookId);
  }
}
