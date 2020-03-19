import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/help/actions/actions.dart';
import 'package:bible_game/app/help/actions/parser.dart';
import 'package:bible_game/app/router/actions.dart';
import 'package:bible_game/app/router/routes.dart';
import 'package:bible_game/app/theme/actions.dart';
import 'package:bible_game/utils/retry.dart';
import 'package:redux_thunk/redux_thunk.dart';

ThunkAction<AppState> goToHelp() {
  return (store) {
    store.dispatch(GoToAction(Routes.help));
    store.dispatch(_initHelp());
    store.dispatch(randomizeTheme());
  };
}

ThunkAction<AppState> _initHelp() {
  return (store) async {
    if (store.state.help == null) {
      try {
        final bundle = store.state.assetBundle;
        final content = await retry(() => bundle.loadString("assets/help.json"));
        final help = parseHelp(content);
        store.dispatch(ReceiveHelp(help));
      } catch (e) {
        print("%%%%%%%%% Error in help initialization %%%%%%%%%%");
        print(e);
      }
    }
  };
}
