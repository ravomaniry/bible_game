import 'package:bible_game/app/theme/themes.dart';
import 'package:bible_game/games/maze/models/board.dart';
import 'package:bible_game/games/maze/models/coordinate.dart';
import 'package:bible_game/games/maze/redux/board_view_model.dart';
import 'package:bible_game/models/word.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';

class Footer extends StatelessWidget {
  final List<Coordinate> _selected;

  Footer(this._selected);

  @override
  Widget build(BuildContext context) {
    return StoreConnector(
      converter: BoardViewModel.converter,
      builder: _builder,
    );
  }

  Widget _builder(_, BoardViewModel viewModel) {
    final theme = viewModel.theme;
    final board = viewModel.state.board;
    final wordsToFind = viewModel.state.wordsToFind;
    return _FooterContainer(
      theme: theme,
      child: Text(
        _getText(wordsToFind, board),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }

  String _getText(List<Word> wordsToFind, Board board) {
    var value = "";
    if (_selected != null) {
      for (final point in _selected) {
        final cell = board.getAt(point.x, point.y).first;
        if (cell.wordIndex >= 0) {
          value += wordsToFind[cell.wordIndex].chars[cell.charIndex].comparisonValue.toUpperCase();
        } else {
          value += "-";
        }
      }
    }
    return value;
  }
}

class _FooterContainer extends StatelessWidget {
  final Widget child;
  final AppColorTheme theme;

  _FooterContainer({
    @required this.child,
    @required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 2, bottom: 4, left: 20, right: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 100),
          child: Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: theme.primaryDark,
              border: Border.all(color: theme.primaryLight, width: 2),
              borderRadius: BorderRadius.all(Radius.circular(16)),
              boxShadow: [
                const BoxShadow(
                  color: Color.fromARGB(180, 0, 0, 0),
                  offset: Offset(2, 2),
                  blurRadius: 2,
                )
              ],
            ),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}
