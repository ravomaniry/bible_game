import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Offset positionOf(Finder finder) {
  final Positioned widget = finder.evaluate().single.widget;
  return Offset(widget.left, widget.top);
}

Future<TestGesture> Function(
  double startX,
  double startY,
  double endX,
  double endY,
) getDragDispatcher(
  WidgetTester tester,
  double xOffset,
  double yOffset,
) {
  return (startX, startY, endX, endY) async {
    final gesture = await tester.startGesture(Offset(startX + xOffset, startY + yOffset));
    await tester.pump();
    await gesture.moveTo(Offset(endX + xOffset, endY + yOffset));
    await tester.pump();
    await gesture.up();
    await tester.pump();
    return gesture;
  };
}
