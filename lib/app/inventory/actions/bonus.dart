import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/inventory/actions/actions.dart';
import 'package:bible_game/app/router/routes.dart';
import 'package:bible_game/games/maze/logic/bonus.dart';
import 'package:bible_game/games/words_in_word/actions/bonus.dart';
import 'package:bible_game/models/bonus.dart';
import 'package:bible_game/sfx/actions.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

ThunkAction<AppState> useBonus(Bonus bonus, bool isTriggeredByUser) {
  return (store) {
    final isUsed = _useBonusInActiveGame(bonus, store);
    if (isTriggeredByUser && isUsed) {
      store.dispatch(DecrementBonus(bonus));
    }
    if (isUsed) {
      store.dispatch(playBonusSfx());
    }
  };
}

bool _useBonusInActiveGame(Bonus _bonus, Store<AppState> store) {
  switch (store.state.route) {
    case Routes.wordsInWord:
    case Routes.anagram:
      return useBonusInWordsInWord(_bonus, store);
    case Routes.maze:
      return useBonusInMaze(_bonus, store);
    default:
      break;
  }
  return false;
}
