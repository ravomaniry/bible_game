import 'package:bible_game/models/word.dart';
import 'package:bible_game/redux/words_in_word/state.dart';

class SubmitWordsInWordResponse {}

class CancelWordsInWordResponse {}

class ResetWordsInWordVerse {}

class UpdateWordsInWordState {
  final WordsInWordState payload;

  UpdateWordsInWordState(this.payload);
}

class SelectWordsInWordChar {
  final Char payload;

  SelectWordsInWordChar(this.payload);
}

class UpdatePropositionAnimation {
  final PropositionAnimations payload;

  UpdatePropositionAnimation(this.payload);
}

UpdatePropositionAnimation triggerPropositionSuccessAnimation() {
  return UpdatePropositionAnimation(PropositionAnimations.success);
}

UpdatePropositionAnimation triggerPropositionFailureAnimation() {
  return UpdatePropositionAnimation(PropositionAnimations.failure);
}

UpdatePropositionAnimation stopPropositionAnimation() {
  return UpdatePropositionAnimation(PropositionAnimations.none);
}

final resetWordsInWord = UpdateWordsInWordState(WordsInWordState(
  cells: [],
  slots: [],
  slotsBackup: [],
  proposition: [],
  wordsToFind: [],
  resolvedWords: [],
));
