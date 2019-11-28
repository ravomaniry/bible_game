import 'dart:async';

Future<T> retry<T>(Future<T> callback(), {int max = 2, int retryAfter = 1}) {
  int retries = 0;
  final completer = Completer<T>();
  void next() {
    callback().then((response) {
      completer.complete(response);
    }).catchError((error) async {
      if (retries < max) {
        await Future.delayed(Duration(seconds: retryAfter));
        next();
      } else {
        completer.completeError(error);
      }
      retries++;
    });
  }

  next();

  return completer.future;
}
