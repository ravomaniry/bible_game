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

  static DbAdapterMock mockMethodsWithDefaultValue(DbAdapterMock adapter) {
    mockMethods(adapter, [
      "init",
      "games",
      "saveGame",
      "games.saveAll",
      "books",
      "getBooksCount",
      "getVersesCount",
      "getBooks",
      "getVerses",
      "getSingleVerse",
      "verses.saveAll",
      "books.saveAll",
      "getBookById",
      "getChapterVersesCount",
      "getVersesNumBetween",
      "getChapterVersesUntil",
    ]);
    return adapter;
  }

  static DbAdapterMock mockMethods(DbAdapterMock adapter, List<String> methods) {
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
            nextVerse: 1,
            versesCount: 10,
            resolvedVersesCount: 0,
            money: 0,
            bonuses: "{}",
          ),
        ]),
      );
    }
    if (methods.contains("saveGame")) {
      when(adapter.saveGame(any)).thenAnswer((_) => Future.value(0));
    }
    if (methods.contains("games.saveAll")) {
      when(adapter.gameModel.saveAll(any)).thenAnswer((_) => Future.value([]));
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
      when(adapter.getVerses(
        any,
        chapter: anyNamed("chapter"),
        verse: anyNamed("verse"),
      )).thenAnswer((_) async {
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
    if (methods.contains("getChapterVersesCount")) {
      when(adapter.getChapterVersesCount(any, any)).thenAnswer((_) => Future.value(10));
    }
    if (methods.contains("getVersesNumBetween")) {
      when(adapter.getVersesNumBetween(
        startBook: anyNamed("startBook"),
        startChapter: anyNamed("startChapter"),
        startVerse: anyNamed("startVerse"),
        endBook: anyNamed("endBook"),
        endChapter: anyNamed("endChapter"),
        endVerse: anyNamed("endVerse"),
      )).thenAnswer((_) async {
        print(_.namedArguments);
        return 10;
      });
    }
    if (methods.contains("getChapterVersesUntil")) {
      when(adapter.getChapterVersesUntil(any, any, any)).thenAnswer((_) async {
        return [
          VerseModel(id: 1, book: 1, chapter: 1, verse: 1, text: "ABC"),
          VerseModel(id: 2, book: 1, chapter: 1, verse: 2, text: "DEF"),
        ];
      });
    }

    return adapter;
  }

  factory DbAdapterMock.withDefaultValues() {
    final adapter = DbAdapterMock();
    return mockMethodsWithDefaultValue(adapter);
  }
}
