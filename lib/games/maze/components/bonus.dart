import 'package:bible_game/app/inventory/components/in_game_bonuses.dart';
import 'package:bible_game/games/maze/redux/board_view_model.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';

class MazeBonus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector(
      converter: BoardViewModel.converter,
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, BoardViewModel viewModel) {
    if (viewModel.state.board == null) {
      return SizedBox.shrink();
    }
    return InGameBonuses();
  }
}
