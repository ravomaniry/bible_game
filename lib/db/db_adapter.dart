import 'package:bible_game/db/model.dart';
import 'package:flutter/foundation.dart';

class DbAdapter {
  final Books books;
  final Verses verses;
  final BibleGameModel model;

  DbAdapter({
    @required this.books,
    @required this.verses,
    @required this.model,
  });
}
