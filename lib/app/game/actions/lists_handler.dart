import 'dart:math';

import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/error/actions.dart';
import 'package:bible_game/app/game/actions/actions.dart';
import 'package:bible_game/app/inventory/actions/actions.dart';
import 'package:bible_game/app/router/actions.dart';
import 'package:bible_game/app/router/routes.dart';
import 'package:bible_game/app/theme/actions.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:bible_game/games/anagram/actions/logic.dart';
import 'package:bible_game/games/maze/actions/init.dart';
import 'package:bible_game/games/words_in_word/actions/logics.dart';
import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/models/game.dart';
import 'package:bible_game/models/game_mode.dart';
import 'package:bible_game/statics/texts.dart';
import 'package:bible_game/utils/retry.dart';
import 'package:redux_thunk/redux_thunk.dart';

final gameModes = [
  GameMode(Routes.wordsInWord, initializeWordsInWord, BlueGrayTheme()),
  GameMode(Routes.anagram, initializeAnagram, GreenTheme()),
  GameMode(Routes.maze, initMaze, AppColorTheme()),
];

ThunkAction<AppState> selectGameHandler(GameModelWrapper _game) {
  return (store) async {
    final model = _game.model;
    try {
      final verse = await retry(
          () => store.state.dba.getSingleVerse(model.nextBook, model.nextChapter, model.nextVerse));
      if (verse == null) {
        store.dispatch(ReceiveError(Errors.unknownDbError()));
      } else {
        final bookName = store.state.game.books.firstWhere((b) => b.id == _game.nextBook).name;
        store.dispatch(UpdateGameVerse(BibleVerse.fromModel(verse, bookName)));
        store.dispatch(UpdateActiveGameId(_game.model.id));
        store.dispatch(UpdateGameCompletedState(false));
        store.dispatch(UpdateInventory(_game.inventory));
        store.dispatch(OpenInventoryDialog(false));
        store.dispatch(initializeRandomGame());
      }
    } catch (e) {
      print(model.name);
      store.dispatch(ReceiveError(Errors.unknownDbError()));
      print("%%%%%%%% error at SelectGame.thunk");
      print(e);
    }
  };
}

ThunkAction<AppState> initializeRandomGame() {
  return (store) {
    final random = Random();
    final sameGameProbability = 0.1;
    final shouldKeepSameGame = random.nextDouble() < sameGameProbability;
    GameMode game;
    if (shouldKeepSameGame) {
      final activeGames = gameModes.where((g) => g.route == store.state.route).toList();
      if (activeGames.isNotEmpty) {
        game = activeGames.first;
      }
    }
    if (game == null) {
      final availableGames = gameModes.where((g) => g.route != store.state.route).toList();
      game = availableGames[random.nextInt(availableGames.length)];
    }
    store.dispatch(initializeGame(game));
  };
}

ThunkAction<AppState> initializeGame(GameMode game) {
  return (store) {
    store.dispatch(game.initAction());
    store.dispatch(UpdateTheme(game.theme));
    store.dispatch(GoToAction(game.route));
  };
}

ThunkAction<AppState> saveActiveGame() {
  return (store) async {
    try {
      final state = store.state.game;
      final model = state.list
          .firstWhere((g) => g.model.id == state.activeId)
          .copyWith(inventory: store.state.game.inventory)
          .toModelHelper();
      await retry(() => store.state.dba.saveGame(model));
      final nextGame = GameModelWrapper.fromModel(model, state.books);
      final nextList = getUpdatedGamesList(nextGame, state.list, state.activeId);
      store.dispatch(ReceiveGamesList(nextList));
    } catch (e) {
      store.dispatch(Errors.unknownDbError());
      print("%%%%%%%%%%%%% error in saveActiveGame ");
      print(e);
    }
  };
}

List<GameModelWrapper> getUpdatedGamesList(
    GameModelWrapper nextGame, List<GameModelWrapper> list, int activeId) {
  return [nextGame]..addAll(list.where((g) => g.model.id != activeId));
}
