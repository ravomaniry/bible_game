import 'dart:typed_data';
import 'dart:ui';

import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/games/maze/actions/actions.dart';
import 'package:bible_game/games/maze/actions/board_utils.dart';
import 'package:bible_game/games/maze/actions/create_board.dart';
import 'package:bible_game/games/maze/redux/state.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:redux_thunk/redux_thunk.dart';

ThunkAction<AppState> initMaze() {
  return (store) async {
    final id = DateTime.now().millisecondsSinceEpoch;
    store.dispatch(UpdateMazeState((store.state.maze ?? MazeState.emptyState()).reset(id)));
    await Future.delayed(Duration(seconds: 1));
    final state = store.state.maze ?? MazeState.emptyState();
    final verse = store.state.game.verse;
    final wordsToFind = getWordsInScopeForMaze(verse);
    final board = await createMazeBoard(verse, id);

    if (store.state.maze.nextId == id) {
      store.dispatch(UpdateMazeState(state.copyWith(
        board: board,
        wordsToFind: wordsToFind,
      )));
    }
    store.dispatch(_loadBackgrounds());
  };
}

ThunkAction<AppState> _loadBackgrounds() {
  return (store) async {
    final current = store.state.maze.backgrounds;
    if (current == null) {
      final backgrounds = Map<String, Image>();
      final List<MapEntry<String, String>> paths = [
        MapEntry("downLeft", "assets/images/maze/down_left.png"),
        MapEntry("downRight", "assets/images/maze/down_right.png"),
        MapEntry("forest", "assets/images/maze/forest.png"),
        MapEntry("frontier", "assets/images/maze/frontier.png"),
        MapEntry("upLeft", "assets/images/maze/up_left.png"),
        MapEntry("upRight", "assets/images/maze/up_right.png"),
        MapEntry("word", "assets/images/maze/word.png"),
      ];

      for (final path in paths) {
        final bytes = await rootBundle.load(path.value);
        final image = await decodeImageFromList(Uint8List.view(bytes.buffer));
        backgrounds.addEntries([MapEntry(path.key, image)]);
      }
      store.dispatch(UpdateMazeState(store.state.maze.copyWith(backgrounds: backgrounds)));
    }
  };
}
