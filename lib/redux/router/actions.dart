import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/router/routes.dart';
import 'package:bible_game/redux/words_in_word/actions.dart';
import 'package:bible_game/redux/words_in_word/state.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:redux/redux.dart';

class GoToAction {
  final Routes payload;

  GoToAction(this.payload);
}

final goToHome = GoToAction(Routes.home);
final goToCalculator = GoToAction(Routes.calculator);

