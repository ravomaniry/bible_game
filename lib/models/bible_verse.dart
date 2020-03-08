import 'package:bible_game/db/model.dart';
import 'package:bible_game/models/word.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class BibleVerse with EquatableMixin {
  final String book;
  final int bookId;
  final int chapter;
  final int verse;
  final String text;
  final List<Word> words;

  BibleVerse({
    @required this.bookId,
    @required this.book,
    @required this.chapter,
    @required this.verse,
    @required this.words,
    @required this.text,
  });

  factory BibleVerse.from({String book, int bookId, int verse, int chapter, String text}) {
    var words = _parseText(text);
    if (words.isEmpty) {
      words = _parseText(_removeIgnoreSymbols(text));
    }
    return BibleVerse(
      book: book,
      chapter: chapter,
      verse: verse,
      words: words,
      bookId: bookId,
      text: text,
    );
  }

  factory BibleVerse.fromModel(VerseModel model, String bookName) {
    return BibleVerse.from(
      bookId: model.book,
      verse: model.verse,
      book: bookName,
      chapter: model.chapter,
      text: model.text,
    );
  }

  BibleVerse copyWith({String book, int bookId, int chapter, int verse, List<Word> words}) {
    return BibleVerse(
      bookId: bookId ?? this.bookId,
      book: book ?? this.book,
      chapter: chapter ?? this.chapter,
      verse: verse ?? this.verse,
      words: words ?? this.words,
      text: this.text,
    );
  }

  BibleVerse copyWithWord(int index, Word word) {
    final words = List<Word>.from(this.words)..[index] = word;
    return copyWith(words: words);
  }

  @override
  String toString() {
    return "$book $chapter:$verse - ${words.length} words: ${words.join("\n")}";
  }

  @override
  List<Object> get props {
    return [book, chapter, verse, words];
  }
}

final separatorRegex = RegExp("[^a-zàôò]", caseSensitive: false);

List<Word> _parseText(String text) {
  var index = 0;
  var wordValue = "";
  var separatorMode = false;
  var isBetweenBraces = false;
  var isBetweenParenthesis = false;
  final List<Word> words = [];

  void appendWord(bool isLastWord) {
    if (wordValue.length > 0) {
      if (!isLastWord || wordValue.trim() != "") {
        words.add(Word.from(wordValue, index, separatorMode));
        separatorMode = false;
        wordValue = "";
        index++;
      }
    }
  }

  for (var i = 0; i < text.length; i++) {
    if (text[i] == "[" || text[i] == "]") {
      isBetweenBraces = !isBetweenBraces;
      continue;
    } else if (text[i] == "(" || text[i] == ")") {
      isBetweenParenthesis = !isBetweenParenthesis;
      continue;
    } else if (isBetweenBraces || isBetweenParenthesis) {
      continue;
    } else if (separatorRegex.hasMatch(text[i])) {
      if (!separatorMode) {
        appendWord(false);
        separatorMode = true;
      }
    } else {
      if (separatorMode) {
        appendWord(false);
      }
    }
    if (!(separatorMode && wordValue.endsWith(" ") && text[i] == " ")) {
      wordValue += text[i];
    }
  }
  appendWord(true);
  return words;
}

String _removeIgnoreSymbols(String text) {
  return text.replaceAll(RegExp(r"\(|\)|\[|\]"), "");
}
