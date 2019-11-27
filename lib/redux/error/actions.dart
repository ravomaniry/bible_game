import 'package:bible_game/redux/error/state.dart';

class ReceiveError {
  final ErrorState payload;

  ReceiveError(this.payload);
}

class DismissError {}
