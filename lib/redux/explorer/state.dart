import 'package:bible_game/db/model.dart';
import 'package:flutter/foundation.dart';

class ExplorerState {
  final List<BookModel> books;
  final BookModel activeBook;
  final List<VerseModel> verses;

  ExplorerState({
    this.books,
    this.activeBook,
    this.verses,
  });

  ExplorerState copyWith({List<BookModel> books, @required BookModel activeBook, List<VerseModel> verses}) {
    return ExplorerState(
      books: books ?? this.books,
      activeBook: activeBook,
      verses: verses ?? this.verses,
    );
  }
}
