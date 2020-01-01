import 'package:bible_game/games/words_in_word/components/words_in_word.dart';
import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/games/anagram/view_model.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';

class Anagram extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AnagramViewModel>(
      key: Key("anagram"),
      converter: AnagramViewModel.converter,
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, AnagramViewModel viewModel) {
    return WordsInWordBody(viewModel);
  }
}
