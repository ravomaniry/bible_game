import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

Future waitForWidget(Finder finder, WidgetTester tester) async {
  final timeout = DateTime.now().millisecondsSinceEpoch + 5000;
  while (DateTime.now().millisecondsSinceEpoch < timeout) {
    final widgets = finder.evaluate();
    if (widgets.isNotEmpty) {
      return;
    } else {
      await _waitFor(50, tester);
    }
  }
}

Future _waitFor(int timeout, WidgetTester tester) {
  final completer = Completer();
  tester.runAsync(() async {
    await Future.delayed(Duration(milliseconds: timeout));
    await tester.pump();
    completer.complete();
  });
  return completer.future;
}
