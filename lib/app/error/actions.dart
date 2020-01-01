import 'package:bible_game/app/error/state.dart';

class ReceiveError {
  final ErrorState payload;

  ReceiveError(this.payload);
}

class DismissError {}
