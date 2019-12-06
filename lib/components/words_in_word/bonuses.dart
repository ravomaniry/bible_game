import 'package:bible_game/redux/words_in_word/view_model.dart';
import 'package:flutter/widgets.dart';

class BonusesDisplay extends StatelessWidget {
  final WordsInWordViewModel _viewModel;

  BonusesDisplay(this._viewModel);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [Text("${_viewModel.money} Ar.")],
    );
  }
}
