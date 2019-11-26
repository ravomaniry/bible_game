import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/word.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Should split words", () {
    final verse = BibleVerse.from(
      book: "Matio",
      chapter: 4,
      verse: 10,
      text: "Aza menatra. Mijoroa",
    );
    final List<Word> words = [
      Word(
        index: 0,
        resolved: false,
        bonus: null,
        chars: [Char(value: "A"), Char(value: "z"), Char(value: "a")],
      ),
      Word(
        index: 1,
        resolved: true,
        bonus: null,
        isSeparator: true,
        chars: [Char(value: " ")],
      ),
      Word(
        index: 2,
        resolved: false,
        bonus: null,
        chars: [
          Char(value: "m"),
          Char(value: "e"),
          Char(value: "n"),
          Char(value: "a"),
          Char(value: "t"),
          Char(value: "r"),
          Char(value: "a"),
        ],
      ),
      Word(
        index: 3,
        bonus: null,
        resolved: true,
        isSeparator: true,
        chars: [Char(value: "."), Char(value: " ")],
      ),
      Word(
        index: 4,
        resolved: false,
        bonus: null,
        chars: [
          Char(value: "M"),
          Char(value: "i"),
          Char(value: "j"),
          Char(value: "o"),
          Char(value: "r"),
          Char(value: "o"),
          Char(value: "a"),
        ],
      )
    ];
    expect(
      verse,
      BibleVerse(book: "Matio", chapter: 4, verse: 10, words: words),
    );
    expect(verse, verse.copyWith());
  });

  test("Copy", () {
    final List<Word> words = [
      Word(
        index: 0,
        resolved: false,
        bonus: null,
        chars: [Char(value: "A"), Char(value: "z"), Char(value: "a")],
      ),
      Word(
        index: 1,
        resolved: false,
        bonus: null,
        chars: [Char(value: ". ")],
      ),
    ];
    final verse = BibleVerse(book: "Marka", chapter: 10, verse: 20, words: words);
    expect(
      verse.copyWith(book: "Matio"),
      BibleVerse(book: "Matio", chapter: 10, verse: 20, words: words),
    );
    expect(
      verse.copyWith(chapter: 1, verse: 2, words: words),
      BibleVerse(book: "Marka", chapter: 1, verse: 2, words: words),
    );
    expect(
      verse.copyWith(book: "Matio", chapter: 1, verse: 2, words: words),
      BibleVerse(book: "Matio", chapter: 1, verse: 2, words: words),
    );
    expect(
      verse.copyWithWord(0, words[0].copyWith(resolved: true)),
      BibleVerse(
        book: "Marka",
        chapter: 10,
        verse: 20,
        words: [
          Word(
            index: 0,
            resolved: true,
            bonus: null,
            chars: [Char(value: "A"), Char(value: "z"), Char(value: "a")],
          ),
          words[1]
        ],
      ),
    );
  });
}
