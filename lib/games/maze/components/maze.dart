import 'package:animator/animator.dart';
import 'package:bible_game/app/game/components/in_game_header.dart';
import 'package:bible_game/games/maze/components/footer.dart';
import 'package:bible_game/games/maze/components/maze_board.dart';
import 'package:bible_game/games/maze/components/path.dart';
import 'package:bible_game/games/maze/components/scroller.dart';
import 'package:bible_game/games/maze/components/tap_handler.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// The aim of this class is to hold states and delegate events handling to the
// underlying handlers
class Maze extends StatefulWidget {
  @override
  _MazeState createState() => _MazeState();
}

class _MazeState extends State<Maze> {
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
    if (handled) {
      _scroller.handleScreenEdge(e);
    } else {
      _scroller.onScroll(e);
    }
  }

  void _onPointerUp(PointerUpEvent e) {
    _tapHandler.onPointerUp(e);
  }

  void _adjustBoardSize(Board board) {
    _scroller.adjustBoardSize(board);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 153, 208, 70),
      body: Column(
        children: [
          InGameHeader(),
          _buildBody(),
          Footer(_tapHandler.selectedCells),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Expanded(
      child: Container(
        child: LayoutBuilder(
          builder: (_, constraints) {
            _scroller.updateContainerSize(constraints);
            return Stack(
              overflow: Overflow.clip,
              children: [
                _ScrollAnimator(
                  onAnimationEnd: _scroller.onAnimationEnd,
                  start: _scroller.animationStart,
                  end: _scroller.animationEnd,
                  origin: _scroller.origin,
                  shouldAnimate: _scroller.shouldAnimate,
                  child: Stack(
                    children: [
                      MazeBoard(
                        onPointerDown: _onPointerDown,
                        onPointerMove: _onPointerMove,
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

class _ScrollAnimator extends StatelessWidget {
  final bool shouldAnimate;
  final Offset start;
  final Offset end;
  final Offset origin;
  final void Function() onAnimationEnd;
  final Widget child;

  _ScrollAnimator({
    @required this.start,
    @required this.end,
    @required this.shouldAnimate,
    @required this.onAnimationEnd,
    @required this.child,
    @required this.origin,
  });

  @override
  Widget build(BuildContext context) {
    if (shouldAnimate && start != null && end != null) {
      return Animator(
        duration: Duration(milliseconds: 600),
        endAnimationListener: (_) => onAnimationEnd(),
        builder: (animation) => Positioned(
          key: Key("board_positioned"),
          top: start.dy + animation.value * (end.dy - start.dy),
          left: start.dx + animation.value * (end.dx - start.dx),
          child: child,
        ),
      );
    } else {
      return Positioned(
        key: Key("board_positioned"),
        top: origin.dy,
        left: origin.dx,
        child: child,
      );
    }
  }
}
