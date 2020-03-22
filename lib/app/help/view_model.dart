import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/help/state.dart';
import 'package:bible_game/app/router/actions.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:flutter/widgets.dart';
import 'package:redux/redux.dart';

class HelpViewModel {
  final HelpState state;
  final AppColorTheme theme;
  final Function closeHandler;

  HelpViewModel({
    @required this.state,
    @required this.theme,
    @required this.closeHandler,
  });
}

HelpViewModel converter(Store<AppState> store) {
  return HelpViewModel(
    state: store.state.help,
    theme: store.state.theme,
    closeHandler: () => store.dispatch(goToHome()),
  );
}
