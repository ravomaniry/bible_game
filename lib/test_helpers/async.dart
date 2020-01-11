import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

Future<T> executeAndAdvanceTimer<T>(Future<T> Function() callback, Duration timeout, WidgetTester tester) {
  final completer = Completer<T>();
  T result;
  callback().then((value) {
    result = value;
  });
  tester.pump(timeout).then((_) => completer.complete(result));
  return completer.future;
}
