import 'package:bible_game/app/game/components/in_game_header.dart';
import 'package:bible_game/games/maze/components/maze_board.dart';
import 'package:bible_game/games/maze/components/scroller.dart';
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
          MazeBoardScroller(
            builder: ({onScroll, adjustBoardSize, screenLimit}) => MazeBoard(
              onScroll: onScroll,
              adjustBoardSize: adjustBoardSize,
              screenLimit: screenLimit,
            ),
          ),
        ],
      ),
    );
  }
}
