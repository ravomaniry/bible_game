import 'package:bible_game/app/theme/themes.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/games/words_in_word/actions/cells_action.dart';
import 'package:bible_game/games/words_in_word/components/result_painter.dart';
import 'package:bible_game/utils/canvas_utils/paint.dart';
import 'package:flutter/cupertino.dart';

class ResultAnimationPainter extends CustomPainter {
  final AppColorTheme theme;
  final List<Coordinate> revealed;
  final double animationValue;
  final PaintersCache painters;

  ResultAnimationPainter({
    @required this.theme,
    @required this.revealed,
    @required this.animationValue,
    @required this.painters,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final point in revealed) {
      final rect = getAnimatedRect(point, animationValue);
      final paint = painters.getFilledRectPaint(theme.neutral);
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(ResultAnimationPainter old) {
    return old.animationValue != animationValue;
  }
}

Rect getAnimatedRect(Coordinate point, double animValue) {
  final maxHeight = cellHeight - cellMargin;
  final maxWidth = cellWidth - cellMargin / 2;
  final width = _getAnimatedDimension(maxWidth, animValue);
  final height = _getAnimatedDimension(maxHeight, animValue);
  final left = cellWidth * point.x + _getAnimatedOffset(width, maxWidth, animValue);
  final top = marginTop + cellHeight * point.y + _getAnimatedOffset(height, maxHeight, animValue);
  return Rect.fromLTRB(left, top, left + width, top + height);
}

double _getAnimatedDimension(double max, double animationValue) {
  return 2 * max * (0.5 - (animationValue - 0.5).abs());
}

double _getAnimatedOffset(double value, double max, double animValue) {
  return animValue < 0.5 ? 0.0 : max - value;
}
