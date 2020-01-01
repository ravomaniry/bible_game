import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/games/maze/actions/board.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Board min size", () {
    final words1 = BibleVerse.from(text: "ABC DEF GHIJ").words;
    final words2 = BibleVerse.from(text: "ABC DEF GHI JKL MNO PQR STU").words;
    expect(getMinSize(words1), 4);
    expect(getMinSize(words2), 5);
  });
}
