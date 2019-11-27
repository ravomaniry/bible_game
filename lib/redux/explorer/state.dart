import 'package:bible_game/db/model.dart';
import 'package:flutter/foundation.dart';

class ExplorerState {
  final List<Books> books;
  final Books activeBook;
  final List<Verses> verses;

  ExplorerState({
    this.books,
    this.activeBook,
    this.verses,
  });

  ExplorerState copyWith({List<Books> books, @required Books activeBook, List<Verses> verses}) {
    return ExplorerState(
      books: books ?? this.books,
      activeBook: activeBook,
      verses: verses ?? this.verses,
    );
  }
}
