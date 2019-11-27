import 'package:bible_game/db/model.dart';

class ExplorerState {
  final List<Books> books;
  final int activeBook;
  final List<Verses> verses;

  ExplorerState({
    this.books,
    this.activeBook,
    this.verses,
  });

  ExplorerState copyWith({List<Books> books, int activeBook, List<Verses> verses}) {
    return ExplorerState(
      books: books ?? this.books,
      activeBook: activeBook ?? this.activeBook,
      verses: verses ?? this.verses,
    );
  }
}
