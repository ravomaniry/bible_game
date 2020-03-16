import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:flutter/widgets.dart';
import 'package:redux/redux.dart';

class ComboViewModel {
  final double combo;
  final AppColorTheme theme;

  ComboViewModel({
    @required this.combo,
    @required this.theme,
  });

  static ComboViewModel converter(Store<AppState> store) {
    return ComboViewModel(
      theme: store.state.theme,
      combo: store.state.game.inventory.combo,
    );
  }
}
