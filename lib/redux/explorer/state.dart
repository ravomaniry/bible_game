import 'package:bible_game/db/model.dart';
import 'package:flutter/foundation.dart';

class ExplorerState {
  final BookModel activeBook;
  final List<VerseModel> verses;

  ExplorerState({
    this.activeBook,
    this.verses,
  });

  ExplorerState copyWith({@required BookModel activeBook, List<VerseModel> verses}) {
    return ExplorerState(
      activeBook: activeBook,
      verses: verses ?? this.verses,
    );
  }
}
