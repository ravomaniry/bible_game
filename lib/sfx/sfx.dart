import 'package:audioplayers/audio_cache.dart';

class Sfx {
  final _shortSuccess = "sfx/short_success.mp3";
  final _longSuccess = "sfx/long_success.mp3";
  final _greeting = "sfx/greeting.mp3";
  final _bonus = "sfx/bonus.mp3";

  void playShortSuccess() {
    _play(_shortSuccess, 0.5);
  }

  void playLongSuccess() {
    _play(_longSuccess, 1);
  }

  void playGreeting() {
    _play(_greeting, 1);
  }

  void playBonus() {
    _play(_bonus, 0.5);
  }

  void _play(String path, double volume) async {
    try {
      await AudioCache().play(path, volume: volume);
    } catch (e) {
      print("%%%%%%%%%% error in playShortSuccess %%%%%%%%%");
    }
  }
}
