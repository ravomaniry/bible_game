class VersesNumRef {
  final int bookId;
  final int chapter;
  final int versesNum;

  VersesNumRef(this.bookId, this.chapter, this.versesNum);
}

class EditorFormData {
  final String name;
  final int startBook;
  final int startChapter;
  final int startVerse;
  final int endBook;
  final int endChapter;
  final int endVerse;
  final List<VersesNumRef> versesNumRefs;

  EditorFormData({
    this.name = "",
    this.startBook = 1,
    this.startChapter = 1,
    this.startVerse = 1,
    this.endBook = 1,
    this.endChapter = 1,
    this.endVerse = 1,
    this.versesNumRefs = const [],
  });

  EditorFormData copyWith({
    final String name,
    final int startBook,
    final int startChapter,
    final int endBook,
    final int endChapter,
    final int endVerse,
    final List<VersesNumRef> versesNumRefs,
  }) {
    return EditorFormData(
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

  EditorFormData appendVersesNum(VersesNumRef versesNumRef) {
    final next = this
        .versesNumRefs
        .where((v) => v.bookId != versesNumRef.bookId && v.chapter != versesNumRef.chapter)
        .toList()
          ..add(versesNumRef);
    return copyWith(versesNumRefs: next);
  }
}
