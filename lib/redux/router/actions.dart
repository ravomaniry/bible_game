import 'package:bible_game/redux/router/routes.dart';

class GoToAction {
  final Routes payload;

  GoToAction(this.payload);
}

final goToHome = GoToAction(Routes.home);
final goToCalculator = GoToAction(Routes.calculator);
final goToWordsInWord = GoToAction(Routes.wordsInWord);
