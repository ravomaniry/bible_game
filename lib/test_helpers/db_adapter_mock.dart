import 'package:bible_game/db/db_adapter.dart';
import 'package:bible_game/db/model.dart';
import 'package:mockito/mockito.dart';

class ModelMock extends Mock implements BibleGameModel {}

class BooksMock extends Mock implements Books {}

class VersesMock extends Mock implements Verses {}

class DbAdapterMock extends Mock implements DbAdapter {
  BibleGameModel model;
  Verses verses;
  Books books;

  DbAdapterMock() {
    this.model = ModelMock();
    this.verses = VersesMock();
    this.books = BooksMock();
  }

  static mockMethodsWithDefaultValue(DbAdapterMock adapter) {
    when(adapter.init()).thenAnswer((_) => Future.value(true));
    when(adapter.getBooksCount()).thenAnswer((_) => Future.value((10)));
    when(adapter.getVersesCount()).thenAnswer((_) => Future.value((10)));
    when(adapter.getBooks()).thenAnswer((_) => Future.value([
          Books(id: 1, name: "Matio", chapters: 10),
          Books(id: 2, name: "Marka", chapters: 20),
        ]));
    when(adapter.getVerses(1)).thenAnswer((_) async {
      return [Verses(book: 1, id: 2, chapter: 3, verse: 4, text: "Ny filazana ny razan'i Jesosy Kristy")];
    });
  }

  factory DbAdapterMock.withDefaultValues() {
    final adapter = DbAdapterMock();
    mockMethodsWithDefaultValue(adapter);
    return adapter;
  }
}
