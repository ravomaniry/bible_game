class VersesNumRef {
  final int bookId;
  final int chapter;
  final int versesNum;

  VersesNumRef(this.bookId, this.chapter, this.versesNum);

  bool isSameRef(int bookId, int chapter) {
    return this.bookId == bookId && this.chapter == chapter;
  }

  @override
  String toString() {
    return "$bookId:$chapter $versesNum";
  }
}

class EditorState {
  final String name;
  final int startBook;
  final int startChapter;
  final int startVerse;
  final int endBook;
  final int endChapter;
  final int endVerse;
  final List<VersesNumRef> versesNumRefs;

  EditorState({
    this.name = "",
    this.startBook = 1,
    this.startChapter = 1,
    this.startVerse = 1,
    this.endBook = 1,
    this.endChapter = 1,
    this.endVerse = 1,
    this.versesNumRefs = const [],
  });

  EditorState copyWith({
    final String name,
    final int startBook,
    final int startChapter,
    final int startVerse,
    final int endBook,
    final int endChapter,
    final int endVerse,
    final List<VersesNumRef> versesNumRefs,
  }) {
    return EditorState(
      name: name ?? this.name,
      startBook: startBook ?? this.startBook,
      startChapter: startChapter ?? this.startChapter,
      startVerse: startVerse ?? this.startVerse,
      endBook: endBook ?? this.endBook,
      endChapter: endChapter ?? this.endChapter,
      endVerse: endVerse ?? this.endVerse,
      versesNumRefs: versesNumRefs ?? this.versesNumRefs,
    );
  }

  EditorState appendVersesNum(VersesNumRef versesNumRef) {
    final next = this.versesNumRefs.where((v) => !v.isSameRef(versesNumRef.bookId, versesNumRef.chapter)).toList()
      ..add(versesNumRef);
    return copyWith(versesNumRefs: next);
  }
}
