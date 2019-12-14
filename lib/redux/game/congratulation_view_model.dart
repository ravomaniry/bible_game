import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/router/actions.dart';
import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';

class CongratulationsViewModel {
  Function closeHandler;

  CongratulationsViewModel({@required this.closeHandler});

  static CongratulationsViewModel converter(Store<AppState> store) {
    return CongratulationsViewModel(
      closeHandler: () => store.dispatch(goToHome),
    );
  }
}
