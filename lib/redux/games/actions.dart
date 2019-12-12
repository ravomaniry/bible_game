import 'package:bible_game/db/model.dart';
import 'package:bible_game/models/game.dart';

class ReceiveGamesList {
  final List<GameModelWrapper> payload;

  ReceiveGamesList(this.payload);
}

class ReceiveBooksList {
  final List<BookModel> payload;

  ReceiveBooksList(this.payload);
}

class ToggleGamesEditorDialog {}
