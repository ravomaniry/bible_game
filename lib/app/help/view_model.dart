import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/help/state.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:flutter/widgets.dart';
import 'package:redux/redux.dart';

class HelpViewModel {
  final HelpState state;
  final AppColorTheme theme;

  HelpViewModel({
    @required this.state,
    @required this.theme,
  });
}

HelpViewModel converter(Store<AppState> store) {
  return HelpViewModel(
    state: store.state.help,
    theme: store.state.theme,
  );
}
