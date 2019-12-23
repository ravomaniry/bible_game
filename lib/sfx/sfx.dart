import 'package:audioplayers/audio_cache.dart';

class Sfx {
  final _shortSuccess = "sfx/short_success.mp3";
  final _longSuccess = "sfx/long_success.mp3";
  final _greeting = "sfx/greeting.mp3";
  final _bonus = "sfx/bonus.mp3";

  void playShortSuccess() {
    _play(_shortSuccess);
  }

  void playLongSuccess() {
    _play(_longSuccess);
  }

  void playGreeting() {
    _play(_greeting);
  }

  void playBonus() {
    _play(_bonus);
  }

  void _play(String path) async {
    try {
      await AudioCache().play(path);
    } catch (e) {
      print("%%%%%%%%%% error in playShortSuccess %%%%%%%%%");
    }
  }
}
