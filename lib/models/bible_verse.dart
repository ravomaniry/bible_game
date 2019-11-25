import 'package:bible_game/models/word.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class BibleVerse with EquatableMixin {
  String book;
  int chapter;
  int verse;
  List<Word> words;
  static final separatorRegex = RegExp("[^a-z]", caseSensitive: false);

  BibleVerse({
    @required this.book,
    @required this.chapter,
    @required this.verse,
    @required this.words,
  });

  factory BibleVerse.from({String book, int verse, int chapter, String text}) {
    final List<Word> words = [];
    var index = 0;
    var wordValue = "";
    var separatorMode = false;

    void appendWord() {
      if (wordValue.length > 0) {
        words.add(Word.from(wordValue, index)..resolved = separatorMode);
        separatorMode = false;
        wordValue = "";
        index++;
      }
    }

    for (var i = 0; i < text.length; i++) {
      if (separatorRegex.hasMatch(text[i])) {
        if (!separatorMode) {
          appendWord();
          separatorMode = true;
        }
      } else {
        if (separatorMode) {
          appendWord();
        }
      }
      wordValue += text[i];
    }
    appendWord();

    return BibleVerse(book: book, chapter: chapter, verse: verse, words: words);
  }

  BibleVerse copyWith({String book, int chapter, int verse, List<Word> words}) {
    return BibleVerse(
      book: book ?? this.book,
      chapter: chapter ?? this.chapter,
      verse: verse ?? this.verse,
      words: words ?? this.words,
    );
  }

  BibleVerse copyWithWord(int index, Word word) {
    final words = List<Word>.from(this.words)..[index] = word;
    return copyWith(words: words);
  }

  @override
  String toString() {
    return "$book $chapter:$verse - ${words.length} words: ${words.join("; ")}";
  }

  @override
  List<Object> get props {
    return [book, chapter, verse, words];
  }
}
