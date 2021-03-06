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

  Future<int> saveGame(GameModel game) => game.save();

  Future<int> get booksCount =>
      bookModel?.select(columnsToSelect: [BookModelFields.name.count()])?.toCount();

  Future<int> get versesCount =>
      verseModel?.select(columnsToSelect: [VerseModelFields.id.count()])?.toCount();

  Future<List<BookModel>> get books => bookModel?.select()?.toList();

  Future resetVerses() async {
    await db.execSQL("DELETE FROM ${TableVerseModel.getInstance.tableName};");
  }

  Future<List<VerseModel>> getVerses(int bookId, {int chapter, int verse}) async {
    if (verseModel == null) {
      return null;
    } else if (chapter == null) {
      return verseModel.select().book.equals(bookId).toList();
    } else {
      return verseModel
          .select()
          .book
          .equals(bookId)
          .and
          .chapter
          .equals(chapter)
          .and
          .verse
          .greaterThanOrEquals(verse ?? 1)
          .toList();
    }
  }

  Future<List<VerseModel>> getChapterVersesUntil(int bookId, int chapter, int verse) {
    return verseModel
        .select()
        .book
        .equals(bookId)
        .and
        .chapter
        .equals(chapter)
        .and
        .verse
        .lessThanOrEquals(verse)
        .toList();
  }

  Future<int> getChapterVersesCount(int bookId, int chapter) {
    if (verseModel == null) {
      return null;
    }
    return verseModel
        .select(columnsToSelect: [VerseModelFields.id.count()])
        .book
        .equals(bookId)
        .and
        .chapter
        .equals(chapter)
        .toCount();
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

  Future<int> getVersesNumBetween({
    @required startBook,
    @required startChapter,
    @required startVerse,
    @required endBook,
    @required endChapter,
    @required endVerse,
  }) async {
    final query = "SELECT COUNT(*) as count FROM ${TableVerseModel.getInstance.tableName} "
        "WHERE "
        " book >= $startBook AND book <= $endBook"
        "   AND NOT ("
        "     (book = $startBook AND chapter < $startChapter) OR (book = $endBook AND chapter > $endChapter)"
        "   ) AND NOT ("
        "     (book = $startBook AND chapter = $startChapter AND verse < $startVerse) OR "
        "     (book = $endBook AND chapter = $endChapter AND verse > $endVerse)"
        "   )";
    final result = await db.execDataTable(query);
    return result[0]["count"];
  }
}
