import 'package:bible_game/app/game/actions/actions.dart';
import 'package:bible_game/app/game/reducer/state.dart';
import 'package:bible_game/app/inventory/actions/actions.dart';
import 'package:bible_game/app/inventory/reducer/reducer_utils.dart';

GameState gamesListStateReducer(GameState state, action) {
  if (action is UpdateGameState) {
    return action.payload;
  } else if (action is ReceiveGamesList) {
    return state.copyWith(list: action.payload);
  } else if (action is ReceiveBooksList) {
    return state.copyWith(books: action.payload);
  } else if (action is ToggleGamesEditorDialog) {
    return _toggleAndResetDialogA(state);
  } else if (action is UpdateGameVerse) {
    return state.copyWith(verse: action.payload);
  } else if (action is UpdateActiveGameId) {
    return state.copyWith(activeId: action.payload);
  } else if (action is UpdateGameResolvedState) {
    return state.copyWith(isResolved: action.payload);
  } else if (action is UpdateGameCompletedState) {
    return state.copyWith(activeGameIsCompleted: action.payload);
  } else if (action is UpdateInventory) {
    return state.copyWith(inventory: action.payload);
  } else if (action is OpenInventoryDialog) {
    return state.copyWith(inventory: state.inventory.copyWith(isOpen: true, isInGame: action.isInGame));
  } else if (action is CloseInventoryDialog) {
    return state.copyWith(inventory: state.inventory.copyWith(isOpen: false));
  } else if (action is BuyBonus) {
    return state.copyWith(inventory: buyBonusReducerUtil(state.inventory, action.payload));
  } else if (action is DecrementBonus) {
    return state.copyWith(inventory: decrementBonusReducerUtil(state.inventory, action.payload));
  } else if (action is InvalidateCombo) {
    return state.copyWith(inventory: state.inventory.copyWith(combo: 1));
  }
  return state;
}

GameState _toggleAndResetDialogA(GameState state) {
  return state.copyWith(
    dialogIsOpen: !state.dialogIsOpen,
    startBook: -1,
    startChapter: -1,
    startVerse: -1,
    endBook: -1,
    endChapter: -1,
    endVerse: -1,
  );
}
