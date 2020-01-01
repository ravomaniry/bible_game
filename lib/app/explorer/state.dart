import 'package:bible_game/db/model.dart';

class ExplorerState {
  final int activeBook;
  final int activeChapter;
  final int activeVerse;
  final bool submitted;
  final List<VerseModel> verses;

  ExplorerState({
    this.verses = const [],
    this.activeBook = 1,
    this.activeChapter = 1,
    this.activeVerse = 1,
    this.submitted = false,
  });

  ExplorerState copyWith({
    List<VerseModel> verses,
    int activeBook,
    int activeChapter,
    int activeVerse,
    bool submitted,
  }) {
    return ExplorerState(
      activeBook: activeBook ?? this.activeBook,
      activeChapter: activeChapter ?? this.activeChapter,
      activeVerse: activeVerse ?? this.activeVerse,
      verses: verses,
      submitted: submitted ?? this.submitted,
    );
  }

  ExplorerState reset() {
    return ExplorerState();
  }
}
