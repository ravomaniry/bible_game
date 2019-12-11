import 'package:bible_game/db/db_adapter.dart';
import 'package:bible_game/db/model.dart';
import 'package:mockito/mockito.dart';

class ModelMock extends Mock implements BibleGameModel {}

class BookModelMock extends Mock implements BookModel {}

class VerseModelMock extends Mock implements VerseModel {}

class GameModelMock extends Mock implements GameModel {}

class DbAdapterMock extends Mock implements DbAdapter {
  BookModel bookModel;
  VerseModel verseModel;
  BibleGameModel db;
  GameModel gameModel;

  DbAdapterMock() {
    this.db = ModelMock();
    this.verseModel = VerseModelMock();
    this.bookModel = BookModelMock();
    this.gameModel = GameModelMock();
  }

  static mockMethodsWithDefaultValue(DbAdapterMock adapter) {
    mockMethods(adapter, [
      "init",
      "games",
      "books",
      "getBooksCount",
      "getVersesCount",
      "getBooks",
      "getVerses",
      "getSingleVerse",
      "verses.saveAll",
      "books.saveAll",
      "getBookById",
      "getBookVersesCount",
    ]);
  }

  static mockMethods(DbAdapterMock adapter, List<String> methods) {
    if (methods.contains("init")) {
      when(adapter.init()).thenAnswer((_) => Future.value(true));
    }
    if (methods.contains("games")) {
      when(adapter.games).thenAnswer(
        (_) => Future.value([
          GameModel(
            id: 1,
            name: "Hello",
            startBook: 1,
            startChapter: 1,
            startVerse: 1,
            endBook: 1,
            endChapter: 1,
            endVerse: 10,
            nextBook: 1,
            nextChapter: 1,
            nextVerse: 2,
            versesCount: 10,
            resolvedVersesCount: 0,
            money: 0,
            bonuses: "{}",
          ),
        ]),
      );
    }
    if (methods.contains("books")) {
      when(adapter.books).thenAnswer((_) => Future.value([
            BookModel(id: 1, name: "Matio", chapters: 10),
          ]));
    }
    if (methods.contains("getBooksCount")) {
      when(adapter.booksCount).thenAnswer((_) => Future.value((10)));
    }
    if (methods.contains("getVersesCount")) {
      when(adapter.versesCount).thenAnswer((_) => Future.value((10)));
    }
    if (methods.contains("getBooks")) {
      when(adapter.books).thenAnswer((_) => Future.value([
            BookModel(id: 1, name: "Matio", chapters: 10),
            BookModel(id: 2, name: "Marka", chapters: 20),
          ]));
    }
    if (methods.contains("getVerses")) {
      when(adapter.getVerses(1)).thenAnswer((_) async {
        return [VerseModel(book: 1, id: 2, chapter: 3, verse: 4, text: "Ny filazana ny razan'i Jesosy Kristy")];
      });
    }
    if (methods.contains("getSingleVerse")) {
      when(adapter.getSingleVerse(any, any, any)).thenAnswer((_) async {
        return VerseModel(book: 1, id: 2, chapter: 3, verse: 4, text: "Ny filazana ny razan'i Jesosy Kristy");
      });
    }
    if (methods.contains("getBookById")) {
      when(adapter.getBookById(any)).thenAnswer((_) => Future.value(BookModel(id: 1, name: "Genesisy", chapters: 10)));
    }
    if (methods.contains("verses.saveAll")) {
      when(adapter.verseModel.saveAll(any)).thenAnswer((_) => Future.value());
    }
    if (methods.contains("books.saveAll")) {
      when(adapter.bookModel.saveAll(any)).thenAnswer((_) => Future.value());
    }
    if (methods.contains("getBookVersesCount")) {
      when(adapter.getChapterVersesCount(any, any)).thenAnswer((_) => Future.value(1));
    }
  }

  factory DbAdapterMock.withDefaultValues() {
    final adapter = DbAdapterMock();
    mockMethodsWithDefaultValue(adapter);
    return adapter;
  }
}
