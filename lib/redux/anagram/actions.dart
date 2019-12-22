import 'package:bible_game/redux/app_state.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

// Anagram is a variant of Words in word
ThunkAction<AppState> proposeAnagram = (Store<AppState> store) {
    final state = store.state.wordsInWord;

};
