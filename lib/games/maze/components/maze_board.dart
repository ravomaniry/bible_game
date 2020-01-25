import 'package:bible_game/app/theme/themes.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/maze_cell.dart';
import 'package:bible_game/games/maze/redux/view_model.dart';
import 'package:bible_game/models/word.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';

final double cellSize = 24;

class BoardBody extends StatelessWidget {
  final Function(PointerMoveEvent) onScroll;
  final Function(Board) adjustBoardSize;

  BoardBody({
    @required this.onScroll,
    @required this.adjustBoardSize,
  });

  double _width(MazeViewModel viewModel) => viewModel.state.board.width * cellSize;

  double _height(MazeViewModel viewModel) => viewModel.state.board.height * cellSize;

  @override
  Widget build(BuildContext context) {
    return StoreConnector(
      converter: MazeViewModel.converter,
      builder: _builder,
    );
  }

  void _onPointerDown(PointerDownEvent e) {
    print("Pointer down $e");
  }

  void _onPointerMove(PointerMoveEvent e) {
    onScroll(e);
  }

  Widget _builder(BuildContext context, MazeViewModel viewModel) {
    adjustBoardSize(viewModel.state.board);

    if (viewModel.state.board == null) {
      return _Loader();
    } else {
      return Listener(
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        child: SizedBox(
          width: _width(viewModel),
          height: _height(viewModel),
          child: Column(
            children: viewModel.state.board.value.map((row) => _buildRow(row, viewModel)).toList(),
          ),
        ),
      );
    }
  }

  Widget _buildRow(List<MazeCell> row, MazeViewModel viewModel) {
    return Row(
      children: row
          .map(
            (cell) => _MazeCellWidget(
              theme: viewModel.theme,
              wordsToFind: viewModel.state.wordsToFind,
              cell: cell,
            ),
          )
          .toList(),
    );
  }
}

class _Loader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Loading..."),
    );
  }
}

class _MazeCellWidget extends StatelessWidget {
  final List<Word> wordsToFind;
  final AppColorTheme theme;
  final MazeCell cell;

  _MazeCellWidget({
    @required this.wordsToFind,
    @required this.theme,
    @required this.cell,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cellSize,
      height: cellSize,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _background,
          image: _image,
        ),
        child: Text(_text),
      ),
    );
  }

  String get _text {
    if (wordIndex >= 0 && charIndex >= 0) {
      return wordsToFind[wordIndex].chars[charIndex].value.toUpperCase();
    }
    return "";
  }

  Color get _background {
    switch (cell.environment) {
      case CellEnv.frontier:
        return Color.fromARGB(40, 218, 255, 127);
      case CellEnv.forest:
        return Color.fromARGB(100, 218, 255, 127);
      default:
        return Colors.transparent;
    }
  }

  DecorationImage get _image {
    if (wordIndex >= 0) {
      return DecorationImage(
        image: AssetImage("assets/images/maze/word.png"),
        fit: BoxFit.fill,
      );
    }

    switch (cell.environment) {
      case CellEnv.forest:
        return DecorationImage(
          image: AssetImage("assets/images/maze/forest.png"),
          fit: BoxFit.fill,
        );
      case CellEnv.upLeft:
        return DecorationImage(
          image: AssetImage("assets/images/maze/up_left.png"),
          fit: BoxFit.fill,
        );
      case CellEnv.upRight:
        return DecorationImage(
          image: AssetImage("assets/images/maze/up_right.png"),
          fit: BoxFit.fill,
        );
      case CellEnv.downRight:
        return DecorationImage(
          image: AssetImage("assets/images/maze/down_right.png"),
          fit: BoxFit.fill,
        );
      case CellEnv.downLeft:
        return DecorationImage(
          image: AssetImage("assets/images/maze/down_left.png"),
          fit: BoxFit.fill,
        );
      case CellEnv.frontier:
        return DecorationImage(
          image: AssetImage("assets/images/maze/frontier.png"),
          fit: BoxFit.fill,
        );
      default:
        return null;
    }
  }

  int get wordIndex => cell.first.wordIndex;

  int get charIndex => cell.first.charIndex;
}