import 'package:bible_game/app/theme/themes.dart';
import 'package:flutter/cupertino.dart';

class CharStyles {
  final TextStyle separator;
  final TextStyle worResolved;
  final TextStyle charResolved;
  final TextStyle unresolved;

  CharStyles({
    @required this.separator,
    @required this.worResolved,
    @required this.charResolved,
    @required this.unresolved,
  });

  factory CharStyles.fromTheme(AppColorTheme theme) {
    return CharStyles(
      separator: TextStyle(color: theme.primaryDark, fontWeight: FontWeight.bold),
      worResolved: TextStyle(color: theme.neutral, fontWeight: FontWeight.bold),
      charResolved: TextStyle(color: theme.accentLeft),
      unresolved: TextStyle(color: theme.primary.withAlpha(160)),
    );
  }
}

class CharPainterCache {
  final _textPaintCache = Map<String, Map<TextStyle, TextPainter>>();
  final _filledRectCache = Map<String, Paint>();

  TextPainter getTextPaint(String value, TextStyle style) {
    var byValue = _textPaintCache[value];
    if (byValue == null) {
      byValue = Map();
      _textPaintCache[value] = byValue;
    }
    var painter = byValue[style];
    if (painter == null) {
      final span = TextSpan(text: value, style: style);
      painter = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();
      byValue[style] = painter;
    }
    return painter;
  }

  Paint getFilledRectPaint(Color color, {int alpha = 255}) {
    final key = "${color.toString()}_$alpha";
    var paint = _filledRectCache[key];
    if (paint == null) {
      paint = Paint()
        ..style = PaintingStyle.fill
        ..color = color.withAlpha(alpha);
      _filledRectCache[key] = paint;
    }
    return paint;
  }
}
