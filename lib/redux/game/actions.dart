import 'package:bible_game/db/model.dart';
import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/game.dart';

class ReceiveGamesList {
  final List<GameModelWrapper> payload;

  ReceiveGamesList(this.payload);
}

class ReceiveBooksList {
  final List<BookModel> payload;

  ReceiveBooksList(this.payload);
}

class UpdateGameVerse {
  final BibleVerse payload;

  UpdateGameVerse(this.payload);
}

class ToggleGamesEditorDialog {}

class UpdateActiveGameId {
  final int payload;

  UpdateActiveGameId(this.payload);
}

class UpdateGameResolvedState {
  final bool payload;

  UpdateGameResolvedState(this.payload);
}

class UpdateGameCompletedState {
  final bool payload;

  UpdateGameCompletedState(this.payload);
}
