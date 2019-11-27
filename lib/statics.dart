import 'package:bible_game/redux/error/state.dart';

class Errors {
  static final dbNotReady = ErrorState("DB not ready", "Try restart the app!");
  static final unknownDbError = ErrorState("DB empty error", "Try restart the app");
}
