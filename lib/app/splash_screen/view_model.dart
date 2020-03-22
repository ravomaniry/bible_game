import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:flutter/widgets.dart';
import 'package:redux/redux.dart';

class SplashScreenViewModel {
  final AppColorTheme theme;
  final double dbStatus;

  SplashScreenViewModel({
    @required this.theme,
    @required this.dbStatus,
  });
}

SplashScreenViewModel converter(Store<AppState> store) {
  return SplashScreenViewModel(
    theme: store.state.theme,
    dbStatus: store.state.dbState.status,
  );
}
