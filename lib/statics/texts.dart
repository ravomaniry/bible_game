import 'package:bible_game/app/error/state.dart';

class Errors {
  static final dbNotReady = ErrorState("Tsy vonona ny 'Base de données'", "Avereno sokafana ny application azafady!");

  static unknownDbError() => ErrorState("Foana ny 'Base de données'", "Avereno sokafana ny application azafady!");
}

class TextValues {
  static final confirmExit = "Hiala marina ve ianao?";
  static final bonusPriceNote = "Lafo kokoa ny bonus raha efa any anaty lalao ianao no mividy";
  static final ok = "OK";
}
