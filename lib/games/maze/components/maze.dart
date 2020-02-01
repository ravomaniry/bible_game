import 'package:bible_game/app/game/components/in_game_header.dart';
import 'package:bible_game/games/maze/components/controller.dart';
import 'package:bible_game/games/maze/components/maze_board.dart';
import 'package:bible_game/games/maze/components/path.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Maze extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Key("gameScreen"),
      body: Column(
        children: [
          InGameHeader(),
          MazeController(
            boardBuilder: ({
              onPointerDown,
              adjustBoardSize,
              screenLimit,
              onPointerMove,
              onPointerUp,
            }) =>
                MazeBoard(
              adjustBoardSize: adjustBoardSize,
              screenLimit: screenLimit,
              onPointerDown: onPointerDown,
              onPointerMove: onPointerMove,
              onPointerUp: onPointerUp,
            ),
            pathsBuilder: ({start, end, selected}) => MazePaths(
              start: start,
              end: end,
              selected: selected,
            ),
          ),
        ],
      ),
    );
  }
}
