import 'package:animator/animator.dart';
import 'package:bible_game/games/maze/components/config.dart';
import 'package:bible_game/games/maze/components/maze_board.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/games/maze/redux/animations_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';

final _paint = Paint()
  ..style = PaintingStyle.fill
  ..color = Colors.white;

class MazeAnimations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector(
      converter: AnimationsViewModel.converter,
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, AnimationsViewModel viewModel) {
    if (viewModel.board == null || viewModel.newlyRevealed.isEmpty) {
      return SizedBox.shrink();
    }
    return Animator(
      duration: const Duration(milliseconds: 600),
      builder: (animation) => CustomPaint(
        size: Size(computeBoardPxWidth(viewModel.board), computeBoardPxHeight(viewModel.board)),
        painter: _Painter(
          newlyRevealed: viewModel.newlyRevealed,
          animationValue: animation.value,
        ),
      ),
    );
  }
}

class _Painter extends CustomPainter {
  final List<Coordinate> newlyRevealed;
  final double animationValue;

  _Painter({
    @required this.newlyRevealed,
    @required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final point in newlyRevealed) {
      _paintRect(point, animationValue, canvas);
    }
  }

  void _paintRect(Coordinate point, double animationValue, Canvas canvas) {
    final rect = _getPointRect(point, animationValue);
    canvas.drawRect(rect, _paint);
  }

  @override
  bool shouldRepaint(_) {
    return true;
  }
}

Rect _getPointRect(Coordinate point, double animationValue) {
  final dimension = 2 * cellSize * (0.5 - (animationValue - 0.5).abs());
  final offset = animationValue < 0.5 ? 0.0 : cellSize - dimension;
  final topLeft = Offset(cellSize * point.x, cellSize * point.y);
  return Rect.fromLTRB(
    offset + topLeft.dx,
    offset + topLeft.dy,
    offset + dimension + topLeft.dx,
    offset + dimension + topLeft.dy,
  );
}
