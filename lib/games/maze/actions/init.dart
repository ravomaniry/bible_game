import 'dart:typed_data';
import 'dart:ui';

import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/games/maze/actions/actions.dart';
import 'package:bible_game/games/maze/create/board_utils.dart';
import 'package:bible_game/games/maze/create/create_board.dart';
import 'package:bible_game/games/maze/redux/state.dart';
import 'package:bible_game/games/words_in_word/actions/bonus.dart';
import 'package:bible_game/models/word.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:redux_thunk/redux_thunk.dart';

ThunkAction<AppState> initMaze() {
  return (store) async {
    store.dispatch(addBonusesToVerse());
    store.dispatch(_initState());
    store.dispatch(_loadBackgrounds());
  };
}

ThunkAction<AppState> _initState() {
  return (store) async {
    final id = DateTime.now().millisecondsSinceEpoch;
    store.dispatch(UpdateMazeState((store.state.maze ?? MazeState.emptyState()).reset(id)));
    final state = store.state.maze ?? MazeState.emptyState();
    final verse = store.state.game.verse;
    final words = getWordsInScopeForMaze(verse);
    final board = await createMazeBoard(verse, id);
    if (store.state.maze.nextId == id) {
      store.dispatch(UpdateMazeState(state.copyWith(
        board: board,
        words: words,
        revealed: initialRevealedState(board),
        wordsToFind: _initialWordsToFind(words),
        wordsToConfirm: _initializeWordsToConfirm(words),
        confirmed: [board.start, board.end],
      )));
    }
  };
}

ThunkAction<AppState> _loadBackgrounds() {
  return (store) async {
    final current = store.state.maze.backgrounds;
    if (current == null) {
      final backgrounds = Map<String, Image>();
      final List<MapEntry<String, String>> paths = [
        MapEntry("forest", "assets/images/maze/forest.png"),
        MapEntry("frontier", "assets/images/maze/frontier.png"),
        MapEntry("downLeft", "assets/images/maze/down_left.png"),
        MapEntry("word", "assets/images/maze/word.png"),
        MapEntry("downRight", "assets/images/maze/down_right.png"),
        MapEntry("downLeft2", "assets/images/maze/down_left_2.png"),
        MapEntry("upLeft", "assets/images/maze/up_left.png"),
        MapEntry("upRight", "assets/images/maze/up_right.png"),
        MapEntry("upRight2", "assets/images/maze/up_right_2.png"),
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

List<int> _initialWordsToFind(List<Word> words) {
  final indexes = List<int>();
  for (var i = 0; i < words.length; i++) {
    if (words[i].length > 1) {
      indexes.add(i);
    }
  }
  return indexes;
}

List<int> _initializeWordsToConfirm(List<Word> words) {
  return [for (var i = 0; i < words.length; i++) i];
}
