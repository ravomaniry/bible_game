import 'package:bible_game/games/maze/components/maze_board.dart';
import 'package:bible_game/games/maze/components/path.dart';
import 'package:bible_game/games/maze/components/scroller.dart';
import 'package:bible_game/games/maze/components/tap_handler.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:flutter/widgets.dart';

// The aim of this class is to hold states and delegate events handling to the
// underlying handlers
class MazeController extends StatefulWidget {
  @override
  _MazeControllerState createState() => _MazeControllerState();
}

class _MazeControllerState extends State<MazeController> {
  final _tapHandler = TapHandler();
  final _scroller = Scroller();

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
                  key: Key("board_positioned"),
                  child: Stack(
                    children: [
                      MazeBoard(
                        onPointerDown: _onPointerDown,
                        onPointerMove: _onPointerMove,
                        screenLimit: _scroller.screenLimit,
                        adjustBoardSize: _adjustBoardSize,
                        onPointerUp: _onPointerUp,
                      ),
                      AbsorbPointer(
                        child: MazePaths(
                          start: _tapHandler.lineStart,
                          end: _tapHandler.lineEnd,
                          selected: _tapHandler.selectedCells,
                        ),
                      ),
                    ],
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
