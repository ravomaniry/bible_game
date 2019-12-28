import 'package:bible_game/components/words_in_word/words_in_word.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/words_in_word/anagram_view_model.dart';
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
