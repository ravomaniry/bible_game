import 'package:animator/animator.dart';
import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/game/components/in_game_header.dart';
import 'package:bible_game/games/maze/components/canvas/background.dart';
import 'package:bible_game/games/maze/components/canvas/selection.dart';
import 'package:bible_game/games/maze/components/canvas/words.dart';
import 'package:bible_game/games/maze/components/canvas/words_bg.dart';
import 'package:bible_game/games/maze/components/footer.dart';
import 'package:bible_game/games/maze/components/maze_board.dart';
import 'package:bible_game/games/maze/components/scroller.dart';
import 'package:bible_game/games/maze/components/tap_handler.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/games/maze/redux/view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';

// The aim of this class is to hold states and delegate events handling to the
// underlying handlers

class Maze extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, MazeViewModel>(
      converter: MazeViewModel.converter,
      rebuildOnChange: false,
      builder: (BuildContext context, MazeViewModel viewModel) => MazeController(
        viewModel.propose,
      ),
    );
  }
}

class MazeController extends StatefulWidget {
  final Function(List<Coordinate>) _propose;

  MazeController(this._propose);

  @override
  _MazeState createState() => _MazeState(_propose);
}

class _MazeState extends State<MazeController> {
  final _tapHandler = TapHandler();
  final _scroller = Scroller();
  final _containerKey = GlobalKey();
  final Function(List<Coordinate> cells) _propose;
  Offset _containerOrigin;

  _MazeState(this._propose);

  void _reRender() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _scroller.reRender = _reRender;
    _tapHandler.reRender = _reRender;
    _tapHandler.propose = _propose;
  }

  void _onPointerDown(PointerDownEvent e, Board board) {
    _tapHandler.onPointerDown(e, board);
  }

  void _onPointerMove(PointerMoveEvent e) {
    _updateContainerOrigin();
    final localPosition = e.position - _containerOrigin - _scroller.origin;
    final handled = _tapHandler.onPointerMove(localPosition);
    if (handled) {
      _scroller.handleScreenEdge(localPosition);
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

  void _updateContainerOrigin() {
    if (_containerOrigin == null) {
      RenderBox rb = _containerKey.currentContext.findRenderObject();
      _containerOrigin = rb.localToGlobal(Offset(0, 0));
    }
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
        key: _containerKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            _scroller.updateContainerSize(constraints);

            return Stack(
              overflow: Overflow.clip,
              children: [
                _ScrollAnimator(
                  start: _scroller.animationStart,
                  end: _scroller.animationEnd,
                  origin: _scroller.origin,
                  shouldAnimate: _scroller.isAnimating,
                  child: Stack(
                    children: [
                      MazeBackground(),
                      MazeWordsBackground(),
                      MazeWords(),
                      MazeSelection(
                        start: _tapHandler.lineStart,
                        end: _tapHandler.lineEnd,
                        selected: _tapHandler.selectedCells,
                      ),
                      MazeListener(
                        onPointerDown: _onPointerDown,
                        onPointerMove: _onPointerMove,
                        adjustBoardSize: _adjustBoardSize,
                        onPointerUp: _onPointerUp,
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
  final Widget child;

  _ScrollAnimator({
    @required this.start,
    @required this.end,
    @required this.shouldAnimate,
    @required this.child,
    @required this.origin,
  });

  @override
  Widget build(BuildContext context) {
    if (shouldAnimate && start != null && end != null) {
      return Animator(
        duration: Duration(milliseconds: 600),
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
