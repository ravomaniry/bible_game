import 'package:bible_game/games/maze/components/scroller.dart';
import 'package:bible_game/games/maze/components/tap_handler.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/utils/pair.dart';
import 'package:flutter/widgets.dart';

typedef BoardBuilder = Widget Function({
  Function(Board) adjustBoardSize,
  Pair<Size, Size> screenLimit,
  Function(PointerDownEvent, Board) onPointerDown,
  Function(PointerMoveEvent) onPointerMove,
  Function(PointerUpEvent) onPointerUp,
});

typedef PathsBuilder = Widget Function({
  Offset start,
  Offset end,
});

// The aim of this class is to hold states and delegate events handling to the
// underlying handlers
class MazeController extends StatefulWidget {
  final BoardBuilder boardBuilder;
  final PathsBuilder pathsBuilder;

  MazeController({
    @required this.boardBuilder,
    @required this.pathsBuilder,
  });

  @override
  _MazeControllerState createState() => _MazeControllerState(
        pathsBuilder: pathsBuilder,
        boardBuilder: boardBuilder,
      );
}

class _MazeControllerState extends State<MazeController> {
  final BoardBuilder boardBuilder;
  final PathsBuilder pathsBuilder;
  final _tapHandler = TapHandler();
  final _scroller = Scroller();

  _MazeControllerState({
    @required this.boardBuilder,
    @required this.pathsBuilder,
  });

  void _reRender() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _scroller.reRender = _reRender;
    _tapHandler.reRender = _reRender;
  }

  void _onPointerDown(PointerDownEvent e, Board board) {
    _tapHandler.onPointerDown(e, board);
  }

  void _onPointerMove(PointerMoveEvent e) {
    final handled = _tapHandler.onPointerMove(e);
    if (!handled) {
      _scroller.onScroll(e);
    }
  }

  void _onPointerUp(PointerUpEvent e) {
    _tapHandler.onPointerUp(e);
  }

  void _adjustBoardSize(Board board) {
    _scroller.adjustBoardSize(board);
  }

  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Color.fromARGB(255, 153, 208, 70),
        child: LayoutBuilder(
          builder: (_, constraints) {
            _scroller.updateContainerSize(constraints);
            return Stack(
              overflow: Overflow.clip,
              children: [
                Positioned(
                  top: _scroller.origin.height,
                  left: _scroller.origin.width,
                  child: boardBuilder(
                    adjustBoardSize: _adjustBoardSize,
                    screenLimit: _scroller.screenLimit,
                    onPointerDown: _onPointerDown,
                    onPointerMove: _onPointerMove,
                    onPointerUp: _onPointerUp,
                  ),
                ),
                Positioned(
                  top: _scroller.origin.height,
                  left: _scroller.origin.width,
                  child: AbsorbPointer(
                    child: pathsBuilder(
                      start: _tapHandler.lineStart,
                      end: _tapHandler.lineEnd,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
