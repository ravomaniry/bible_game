import 'package:bible_game/db/db_adapter.dart';
import 'package:bible_game/db/model.dart';
import 'package:bible_game/models/game.dart';
import 'package:bible_game/app/error/actions.dart';
import 'package:bible_game/app/game/actions/actions.dart';
import 'package:bible_game/app/inventory/reducer/state.dart';
import 'package:bible_game/app/theme/actions.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:bible_game/statics/texts.dart';
import 'package:bible_game/utils/retry.dart';

final defaultInventory = InventoryState.emptyState().copyWith(
  revealCharBonus1: 10,
  revealCharBonus2: 5,
  revealCharBonus5: 2,
  revealCharBonus10: 1,
);

final defaultGames = [
  GameModelWrapper(
    nextBook: 1,
    nextChapter: 1,
    nextVerse: 1,
    startBookName: "Matio",
    endBookName: "Jaona",
    resolvedVersesCount: 0,
    inventory: defaultInventory,
    model: GameModel(
      id: 1,
      name: "Filazantsara",
      startBook: 1,
      startChapter: 1,
      startVerse: 1,
      endBook: 4,
      endChapter: 21,
      endVerse: 25,
      versesCount: 1071 + 678 + 1151 + 879,
      resolvedVersesCount: 0,
      money: 0,
      bonuses: "{}",
    ),
  ).toModelHelper(),
  GameModelWrapper(
    nextBook: 5,
    nextChapter: 1,
    nextVerse: 1,
    startBookName: "Asan'ny Apostoly",
    endBookName: "Asan'ny Apostoly",
    resolvedVersesCount: 0,
    inventory: defaultInventory,
    model: GameModel(
      id: 2,
      name: "Asan'ny Apostoly",
      startBook: 5,
      startChapter: 1,
      startVerse: 1,
      endBook: 5,
      endChapter: 28,
      endVerse: 31,
      versesCount: 1007,
      resolvedVersesCount: 0,
      money: 0,
      bonuses: "{}",
    ),
  ).toModelHelper(),
];

Future initializeGames(DbAdapter dba, Function dispatch) async {
  try {
    final books = await retry(() => dba.books);
    if (books == null) {
      dispatch(ReceiveError(Errors.unknownDbError()));
    } else {
      await initializeGamesList(dba, books, dispatch);
    }
  } catch (e) {
    print("%%%%%%%%%%%%% error on initializeGames %%%%%%%%%%%%%");
    print(e);
    dispatch(ReceiveError(Errors.unknownDbError()));
  }
}

Future initializeGamesList(DbAdapter dba, List<BookModel> books, Function dispatch) async {
  try {
    List<GameModel> games = await retry(() => dba.games);
    if (games == null) {
      dispatch(ReceiveError(Errors.unknownDbError()));
    } else {
      if (games.isEmpty) {
        games = defaultGames;
        await retry(() => dba.gameModel.saveAll(games));
      }
      final gamesList = games.map((model) => GameModelWrapper.fromModel(model, books)).toList();
      dispatch(ReceiveBooksList(books));
      dispatch(ReceiveGamesList(gamesList));
      dispatch(UpdateTheme(AppColorTheme()));
    }
  } catch (e) {
    print("%%%%%%%%%%%%% error in initializeGamesList %%%%%%%%%");
    print(e);
    dispatch(ReceiveError(Errors.unknownDbError()));
  }
}