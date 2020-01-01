import 'dart:math';

import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:redux_thunk/redux_thunk.dart';

class UpdateTheme {
  final AppColorTheme payload;

  UpdateTheme(this.payload);
}

final allThemes = [
  AppColorTheme(),
  BlueGrayTheme(),
  GreenTheme(),
];

ThunkAction<AppState> randomizeTheme() {
  return (store) {
    final next = getRandomTheme(store.state.theme.name);
    store.dispatch(UpdateTheme(next));
  };
}

AppColorTheme getRandomTheme(String activeThemeName) {
  final random = Random();
  final eligibleThemes = allThemes.where((t) => t.name != activeThemeName).toList();
  return eligibleThemes[random.nextInt(eligibleThemes.length)];
}
