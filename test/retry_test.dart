import 'package:bible_game/utils/retry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Test retry", () async {
    int retries = -1;
    Future<int> callback() {
      retries++;
      return retries == 0 ? Future.error(null) : Future.value(1);
    }

    expect(await retry<int>(() => callback(), retryAfter: 0), 1);

    final rejectingFuture = () => Future.error(null);
    try {
      final result = await retry(rejectingFuture, retryAfter: 0);
      expect(result is NullThrownError, true);
    } catch (e) {
      expect(e is NullThrownError, true);
    }
  });
}
