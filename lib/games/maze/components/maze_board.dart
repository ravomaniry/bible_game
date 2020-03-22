import 'package:bible_game/app/splash_screen/splash_screen.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:bible_game/games/maze/components/cell.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/redux/board_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';

class MazeListener extends StatelessWidget {
  final Function(Board) adjustBoardSize;
  final Function(PointerDownEvent, Board) onPointerDown;
  final Function(PointerMoveEvent) onPointerMove;
  final Function(PointerUpEvent) onPointerUp;

  MazeListener({
    @required this.adjustBoardSize,
    @required this.onPointerDown,
    @required this.onPointerMove,
    @required this.onPointerUp,
  });

  @override
  Widget build(BuildContext context) {
    return StoreConnector(
      converter: BoardViewModel.converter,
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, BoardViewModel viewModel) {
    final board = viewModel.state.board;
    adjustBoardSize(board);
    if (board == null) {
      return _Loader(viewModel.theme);
    } else {
      return Listener(
        onPointerDown: (e) => onPointerDown(e, board),
        onPointerMove: onPointerMove,
        onPointerUp: onPointerUp,
        key: Key("maze_board"),
        child: AbsorbPointer(
          child: SizedBox(
            width: computeBoardPxWidth(board),
            height: computeBoardPxHeight(board),
          ),
        ),
      );
    }
  }
}

double computeBoardPxWidth(Board board) => board.width * cellSize;

double computeBoardPxHeight(Board board) => board.height * cellSize;

class _Loader extends StatelessWidget {
  final AppColorTheme _theme;

  _Loader(this._theme);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, BoxConstraints constraints) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height / 1.6,
      width: size.width,
      child: Center(
        child: SplashScreenBody(_theme),
      ),
    );
  }
}
