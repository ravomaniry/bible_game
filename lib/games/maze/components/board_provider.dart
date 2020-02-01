import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';

class BoardProvider extends StatelessWidget {
  final Widget Function(Board board) builder;

  BoardProvider({@required this.builder});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, Board>(
      converter: (store) => store.state.maze.board,
      builder: (_, board) => builder(board),
    );
  }
}
