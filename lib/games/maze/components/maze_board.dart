import 'package:bible_game/app/theme/themes.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/maze_cell.dart';
import 'package:bible_game/games/maze/redux/view_model.dart';
import 'package:bible_game/models/word.dart';
import 'package:bible_game/utils/pair.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';

final double cellSize = 24;
final emptyCell = SizedBox(width: cellSize, height: cellSize);

class MazeBoard extends StatelessWidget {
  final Function(PointerMoveEvent) onScroll;
  final Function(Board) adjustBoardSize;
  final Pair<Size, Size> screenLimit;

  MazeBoard({
    @required this.onScroll,
    @required this.adjustBoardSize,
    @required this.screenLimit,
  });

  @override
  Widget build(BuildContext context) {
    return StoreConnector(
      converter: MazeViewModel.converter,
      builder: (context, viewModel) => _BoardBody(
        viewModel: viewModel,
        onScroll: onScroll,
        onScreenLimit: screenLimit,
        adjustBoardSize: adjustBoardSize,
      ),
    );
  }
}

class _BoardBody extends StatelessWidget {
  final Function(PointerMoveEvent) onScroll;
  final Function(Board) adjustBoardSize;
  final Pair<Size, Size> onScreenLimit;
  final MazeViewModel viewModel;

  _BoardBody({
    @required this.viewModel,
    @required this.onScroll,
    @required this.adjustBoardSize,
    @required this.onScreenLimit,
  });

  void _onPointerDown(PointerDownEvent e) {
    print("Pointer down ${e.delta}");
  }

  void _onPointerMove(PointerMoveEvent e) {
    onScroll(e);
  }

  double get _width => viewModel.state.board.width * cellSize;

  double get _height => viewModel.state.board.height * cellSize;

  @override
  Widget build(BuildContext context) {
    adjustBoardSize(viewModel.state.board);
    if (viewModel.state.board == null) {
      return _Loader();
    } else {
      return Listener(
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        child: SizedBox(
          width: _width,
          height: _height,
          child: Column(
            children: _buildRows(),
          ),
        ),
      );
    }
  }

  List<Widget> _buildRows() {
    final minX = onScreenLimit.first.width.toInt();
    final minY = onScreenLimit.first.height.toInt();
    final maxX = onScreenLimit.last.width.toInt();
    final maxY = onScreenLimit.last.height.toInt();
    final rows = List<Row>(maxY);
    for (var y = 0; y < maxY; y++) {
      if (y < minY) {
        rows[y] = Row(children: [emptyCell]);
      } else {
        final children = List<Widget>(maxX);
        for (var x = 0; x < maxX; x++) {
          if (x < minX) {
            children[x] = emptyCell;
          } else {
            children[x] = _MazeCellWidget(
              theme: viewModel.theme,
              cell: viewModel.state.board.getAt(x, y),
              wordsToFind: viewModel.state.wordsToFind,
            );
          }
        }
        rows[y] = Row(children: children);
      }
    }
    return rows;
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
