import 'package:bible_game/db/db_adapter.dart';
import 'package:bible_game/db/model.dart';
import 'package:mockito/mockito.dart';

class ModelMock extends Mock implements BibleGameModel {}

class BooksMock extends Mock implements BookModel {}

class VersesMock extends Mock implements VerseModel {}

class DbAdapterMock extends Mock implements DbAdapter {
  BibleGameModel model;
  VerseModel verses;
  BookModel books;

  DbAdapterMock() {
    this.model = ModelMock();
    this.verses = VersesMock();
    this.books = BooksMock();
  }

  static mockMethodsWithDefaultValue(DbAdapterMock adapter) {
    mockMethods(adapter, [
      "init",
      "getBooksCount",
      "getVersesCount",
      "getBooks",
      "getVerses",
      "getSingleVerse",
      "verses.saveAll",
      "books.saveAll",
      "getBookById",
    ]);
  }

  static mockMethods(DbAdapterMock adapter, List<String> methods) {
    if (methods.contains("init")) {
      when(adapter.init()).thenAnswer((_) => Future.value(true));
    }
    if (methods.contains("getBooksCount")) {
      when(adapter.getBooksCount()).thenAnswer((_) => Future.value((10)));
    }
    if (methods.contains("getVersesCount")) {
      when(adapter.getVersesCount()).thenAnswer((_) => Future.value((10)));
    }
    if (methods.contains("getBooks")) {
      when(adapter.getBooks()).thenAnswer((_) => Future.value([
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
      when(adapter.verses.saveAll(any)).thenAnswer((_) => Future.value());
    }
    if (methods.contains("books.saveAll")) {
      when(adapter.books.saveAll(any)).thenAnswer((_) => Future.value());
    }
  }

  factory DbAdapterMock.withDefaultValues() {
    final adapter = DbAdapterMock();
    mockMethodsWithDefaultValue(adapter);
    return adapter;
  }
}
