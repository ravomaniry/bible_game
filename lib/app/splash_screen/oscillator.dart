import 'dart:math';
import 'dart:ui';

import 'package:animator/animator.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final _waveLength = 10.0;
final _duration = Duration(milliseconds: 500);
final _word = ["J", "E", "S", "O", "S", "Y"];
final _cellSize = 24.0;
final _spacing = 6.0;
final _maxStep = _waveLength / 2;
final _height = _cellSize * 5;
final _width = (_cellSize + _spacing) * _word.length - _spacing;
final _cellRadius = Radius.circular(4);
final _canvasSize = Size(_width, _height + _cellSize);

class WordsOscillator extends StatefulWidget {
  final AppColorTheme _theme;

  WordsOscillator(this._theme);

  @override
  _WordsOscillatorState createState() => _WordsOscillatorState(_theme);
}

class _WordsOscillatorState extends State<WordsOscillator> {
  final AppColorTheme _theme;
  var _ys = _word.map((_) => _height / 2).toList();
  var _controlPoint = Offset(_width / 2, _height / 2);
  final _leftPoint = Offset(0, _height / 2);
  final _rightPoint = Offset(_width, _height / 2);

  _WordsOscillatorState(this._theme);

  void _onPointerEvent(PointerEvent e) {
    setState(() {
      var position = e.localPosition;
      if (position.dy > _height) {
        position = Offset(position.dx, _height);
      } else if (position.dy < 0) {
        position = Offset(position.dx, 0);
      }
      _controlPoint = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerEvent,
      onPointerMove: _onPointerEvent,
      child: Animator(
        repeats: -1,
        duration: _duration,
        builder: (Animation anim) {
          _updateYs(anim.value);
          return CustomPaint(
            size: _canvasSize,
            painter: _Painter(_ys, _theme),
          );
        },
      ),
    );
  }

  void _updateYs(double ratio) {
    for (var index = 0, max = _ys.length; index < max; index++) {
      _ys[index] = getY(
        index,
        _makeRatioOdd(ratio, index),
        _leftPoint,
        _controlPoint,
        _rightPoint,
        _ys[index],
      );
    }
  }
}

class _Painter extends CustomPainter {
  final List<double> _ys;
  final AppColorTheme _theme;
  final Paint _cellPaint = Paint()..style = PaintingStyle.fill;

  static final _textPainters = _word
      .map((text) => TextPainter(
            text: TextSpan(
              text: text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout())
      .toList();

  _Painter(this._ys, this._theme) {
    _cellPaint.color = _theme.primary;
    _cellPaint.strokeWidth = 2;
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0, length = _ys.length; i < length; i++) {
      final x = _indexToX(i);
      final y = _ys[i];
      _drawRect(x, y, canvas);
      _drawText(i, x, y, canvas);
    }
  }

  void _drawRect(double x, double y, Canvas canvas) {
    final rRect = RRect.fromLTRBR(x, y, x + _cellSize, y + _cellSize, _cellRadius);
    canvas.drawRRect(rRect, _cellPaint);
  }

  void _drawText(int index, double x, double y, Canvas canvas) {
    _textPainters[index].paint(canvas, Offset(x + _cellSize / 4, y + 4));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

double _indexToX(int index) => (_cellSize + _spacing) * index;

double _makeRatioOdd(double ratio, int index) {
  if (index % 2 == 0) {
    return 1 - ratio;
  }
  return ratio;
}

double getY(
  int index,
  double ratio,
  Offset mostLeftPoint,
  Offset controlPoint,
  Offset mostRightPoint,
  double prevValue,
) {
  final centerX = (_cellSize + _spacing) * (index + 0.5);
  final zero = centerX > controlPoint.dx ? controlPoint : mostLeftPoint;
  final one = centerX > controlPoint.dx ? mostRightPoint : controlPoint;
  final centerY = lerpDouble(zero.dy, one.dy, (centerX - zero.dx) / (one.dx - zero.dx));
  final dy = _waveLength * sin(2 * pi * ratio) / 2;
  final targetY = (centerY + dy).round().toDouble();
  if ((targetY - prevValue).abs() < _maxStep) {
    return targetY;
  } else if (targetY > prevValue) {
    return prevValue + _maxStep;
  } else {
    return prevValue - _maxStep;
  }
}
