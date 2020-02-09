import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Offset positionOf(Finder finder) {
  final Positioned widget = finder.evaluate().single.widget;
  return Offset(widget.left, widget.top);
}
