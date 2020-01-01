import 'package:bible_game/models/bible_verse.dart';
import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/inventory/reducer/state.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:flutter/widgets.dart';
import 'package:redux/redux.dart';

class GameHeaderViewModel {
  final BibleVerse verse;
  final InventoryState inventory;
  final AppColorTheme theme;

  GameHeaderViewModel({
    @required this.verse,
    @required this.inventory,
    @required this.theme,
  });

  static GameHeaderViewModel converter(Store<AppState> store) {
    return GameHeaderViewModel(
      theme: store.state.theme,
      verse: store.state.game.verse,
      inventory: store.state.game.inventory,
    );
  }
}
