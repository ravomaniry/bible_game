import 'dart:math';

import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/themes/themes.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

class UpdateTheme {
  final AppColorTheme payload;

  UpdateTheme(this.payload);
}

final random = Random();

final allThemes = [
  AppColorTheme(),
  BlueGrayTheme(),
  GreenTheme(),
];

ThunkAction<AppState> randomizeTheme = (Store<AppState> store) {
  final next = getRandomTheme(store.state.theme.name);
  store.dispatch(UpdateTheme(next));
};

AppColorTheme getRandomTheme(String activeThemeName) {
  final eligibleThemes = allThemes.where((t) => t.name != activeThemeName).toList();
  return eligibleThemes[random.nextInt(eligibleThemes.length)];
}
