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

final triggerPropositionSuccessAnimation = UpdatePropositionAnimation(PropositionAnimations.success);
final triggerPropositionFailureAnimation = UpdatePropositionAnimation(PropositionAnimations.failure);
final stopPropositionAnimation = UpdatePropositionAnimation(PropositionAnimations.none);

final resetWordsInWord = UpdateWordsInWordState(WordsInWordState(
  cells: [],
  slots: [],
  slotsBackup: [],
  proposition: [],
  wordsToFind: [],
  resolvedWords: [],
));
