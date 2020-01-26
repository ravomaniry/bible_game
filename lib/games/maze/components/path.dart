import 'dart:math';

import 'package:flutter/widgets.dart';

final _selectPaint = Paint()
  ..style = PaintingStyle.stroke
  ..color = Color.fromARGB(100, 255, 0, 0)
  ..strokeWidth = 10;

class MazePaths extends StatelessWidget {
  final Offset start;
  final Offset end;

  MazePaths({@required this.start, @required this.end});

  @override
  Widget build(BuildContext context) {
    if (start != null && end != null) {
      return CustomPaint(
        painter: _Painter(start: start, end: end),
        size: Size(
          max(start.dx, end.dx) + 20,
          max(start.dy, end.dy) + 20,
        ),
      );
    }
    return SizedBox.shrink();
  }
}

class _Painter extends CustomPainter {
  final Offset start;
  final Offset end;

  _Painter({@required this.start, @required this.end});

  @override
  void paint(Canvas canvas, Size size) {
    if (start != null && end != null) {
      canvas.drawLine(start, end, _selectPaint);
    }
  }

  @override
  bool shouldRepaint(_Painter old) {
    if (start != null && end != null && old.start != null && old.end != null) {
      final diff = sqrt(start.dx - old.start.dx) + sqrt(start.dy - old.start.dy);
      return diff > 12;
    }
    return true;
  }
}
