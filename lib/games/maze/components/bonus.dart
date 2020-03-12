import 'package:bible_game/app/app_state.dart';
import 'package:bible_game/app/inventory/components/in_game_bonuses.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

bool _converter(Store<AppState> store) {
  return store.state.maze.board != null;
}

class MazeBonus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector(
      converter: _converter,
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, bool isReady) {
    if (isReady) {
      return InGameBonuses();
    }
    return SizedBox.shrink();
  }
}
