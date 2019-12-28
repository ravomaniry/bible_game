import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/word.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Should split words with all its rules", () {
    final verse = BibleVerse.from(
      book: "Matio",
      chapter: 4,
      verse: 10,
      text: "Azà menatra. (jer 1.30) Mijòrôa [Gr. teny]",
    );
    final List<Word> words = [
      Word(
        index: 0,
        resolved: false,
        bonus: null,
        value: "Azà",
        chars: [
          Char(value: "A", comparisonValue: "a"),
          Char(value: "z", comparisonValue: "z"),
          Char(value: "à", comparisonValue: "a"),
        ],
      ),
      Word(
        index: 1,
        resolved: true,
        bonus: null,
        isSeparator: true,
        value: " ",
        chars: [Char(value: " ", comparisonValue: " ")],
      ),
      Word(
        index: 2,
        resolved: false,
        bonus: null,
        value: "menatra",
        chars: [
          Char(value: "m", comparisonValue: "m"),
          Char(value: "e", comparisonValue: "e"),
          Char(value: "n", comparisonValue: "n"),
          Char(value: "a", comparisonValue: "a"),
          Char(value: "t", comparisonValue: "t"),
          Char(value: "r", comparisonValue: "r"),
          Char(value: "a", comparisonValue: "a"),
        ],
      ),
      Word(
        index: 3,
        bonus: null,
        resolved: true,
        isSeparator: true,
        value: ". ",
        chars: [
          Char(value: ".", comparisonValue: "."),
          Char(value: " ", comparisonValue: " "),
        ],
      ),
      Word(
        index: 4,
        resolved: false,
        bonus: null,
        value: "Mijòrôa",
        chars: [
          Char(value: "M", comparisonValue: "m"),
          Char(value: "i", comparisonValue: "i"),
          Char(value: "j", comparisonValue: "j"),
          Char(value: "ò", comparisonValue: "o"),
          Char(value: "r", comparisonValue: "r"),
          Char(value: "ô", comparisonValue: "o"),
          Char(value: "a", comparisonValue: "a"),
        ],
      )
    ];
    expect(
      verse,
      BibleVerse(
        book: "Matio",
        bookId: 1,
        chapter: 4,
        verse: 10,
        words: words,
        text: "Azà menatra. Mijòrôa [Gr. teny]",
      ),
    );
    expect(verse, verse.copyWith());
  });

  test("Copy", () {
    final List<Word> words = [
      Word(
        index: 0,
        resolved: false,
        bonus: null,
        value: "Aza",
        chars: [
          Char(value: "A", comparisonValue: "a"),
          Char(value: "z", comparisonValue: "z"),
          Char(value: "a", comparisonValue: "a"),
        ],
      ),
      Word(
        index: 1,
        resolved: false,
        bonus: null,
        value: ".",
        chars: [Char(value: ".", comparisonValue: ".")],
      ),
    ];
    final verse = BibleVerse(
      book: "Marka",
      bookId: 1,
      chapter: 10,
      verse: 20,
      words: words,
      text: "Aza .",
    );
    expect(
      verse.copyWith(book: "Matio"),
      BibleVerse(
        book: "Matio",
        bookId: 1,
        chapter: 10,
        verse: 20,
        words: words,
        text: "Aza .",
      ),
    );
    expect(
      verse.copyWith(chapter: 1, verse: 2, words: words),
      BibleVerse(book: "Marka", bookId: 1, chapter: 1, verse: 2, words: words, text: "Aza ."),
    );
    expect(
      verse.copyWith(book: "Matio", chapter: 1, verse: 2, words: words),
      BibleVerse(
        book: "Matio",
        bookId: 1,
        chapter: 1,
        verse: 2,
        words: words,
        text: "Aza .",
      ),
    );
    expect(
      verse.copyWithWord(0, words[0].copyWith(resolved: true)),
      BibleVerse(
        book: "Marka",
        chapter: 10,
        verse: 20,
        bookId: 1,
        text: "Aza .",
        words: [
          Word(
            index: 0,
            resolved: true,
            bonus: null,
            value: "Aza",
            chars: [
              Char(value: "A", comparisonValue: "a"),
              Char(value: "z", comparisonValue: "z"),
              Char(value: "a", comparisonValue: "a"),
            ],
          ),
          words[1]
        ],
      ),
    );
  });
}
