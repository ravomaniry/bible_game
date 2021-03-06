import 'package:animator/animator.dart';
import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/game/components/in_game_header.dart';
import 'package:bible_game/app/inventory/components/combo.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:bible_game/games/maze/components/bonus.dart';
import 'package:bible_game/games/maze/components/canvas/background.dart';
import 'package:bible_game/games/maze/components/canvas/cell_animations.dart';
import 'package:bible_game/games/maze/components/canvas/paths.dart';
import 'package:bible_game/games/maze/components/canvas/selection.dart';
import 'package:bible_game/games/maze/components/canvas/words.dart';
import 'package:bible_game/games/maze/components/canvas/words_bg.dart';
import 'package:bible_game/games/maze/components/config.dart';
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
    return Scaffold(
      key: Key("gameScreen"),
      body: StoreConnector<AppState, MazeViewModel>(
        converter: MazeViewModel.converter,
        builder: (BuildContext context, MazeViewModel viewModel) => MazeController(
          viewModel.propose,
          viewModel.theme,
        ),
      ),
    );
  }
}

class MazeController extends StatefulWidget {
  final Function(List<Coordinate>) _propose;
  final AppColorTheme _theme;

  MazeController(this._propose, this._theme);

  @override
  _MazeState createState() => _MazeState(_propose, _theme);
}

class _MazeState extends State<MazeController> {
  final AppColorTheme _theme;
  final _tapHandler = TapHandler();
  final _scroller = Scroller();
  final _containerKey = GlobalKey();
  final Function(List<Coordinate> cells) _propose;
  Offset _containerOrigin;
  Board _board;

  _MazeState(this._propose, this._theme);

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
    _board = board;
    _updateContainerOrigin();
    final localPosition = e.position - _containerOrigin - _scroller.origin;
    if (_isInsideContainer(e.position, localPosition)) {
      _tapHandler.onPointerDown(localPosition, board);
    }
  }

  void _onPointerMove(PointerMoveEvent e) {
    _updateContainerOrigin();
    final localPosition = e.position - _containerOrigin - _scroller.origin;
    if (_isInsideContainer(e.position, localPosition)) {
      final handled = _tapHandler.onPointerMove(localPosition, _board);
      if (handled) {
        _scroller.handleScreenEdge(localPosition);
      } else {
        _scroller.onScroll(e);
      }
    }
  }

  void _onPointerUp(PointerUpEvent e) {
    _tapHandler.onPointerUp(e);
  }

  void _adjustBoardSize(Board board) {
    _scroller.adjustBoardSize(board);
    if (_board != board) {
      _board = board;
    }
  }

  void _updateContainerOrigin() {
    if (_containerOrigin == null) {
      RenderBox rb = _containerKey.currentContext.findRenderObject();
      _containerOrigin = rb.localToGlobal(Offset(0, 0));
    }
  }

  bool _isInsideContainer(Offset gPos, Offset localPos) {
    return gPos.dx >= _containerOrigin.dx &&
        gPos.dy >= _containerOrigin.dy &&
        (gPos.dx <= _containerOrigin.dx + _scroller.containerSize.width) &&
        (gPos.dy <= _containerOrigin.dy + _scroller.containerSize.height &&
            localPos.dx < _board.width * cellSize &&
            localPos.dy < _board.height * cellSize);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(_theme.background),
          fit: BoxFit.fill,
        ),
      ),
      child: Column(
        children: [
          InGameHeader(),
          _buildBody(),
          ComboDisplay(),
          Footer(_tapHandler.selectedCells),
          MazeBonus(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 153, 208, 70),
          borderRadius: BorderRadius.circular(6),
        ),
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
                      MazePaths(),
                      MazeAnimations(),
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
