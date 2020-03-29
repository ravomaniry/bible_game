import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/router/actions.dart';
import 'package:bible_game/app/texts.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';

class CongratulationsViewModel {
  final Function closeHandler;
  final AppColorTheme theme;
  final AppTexts texts;

  CongratulationsViewModel({
    @required this.closeHandler,
    @required this.theme,
    @required this.texts,
  });

  static CongratulationsViewModel converter(Store<AppState> store) {
    return CongratulationsViewModel(
      closeHandler: () => store.dispatch(goToHome()),
      theme: store.state.theme,
      texts: store.state.texts,
    );
  }
}
