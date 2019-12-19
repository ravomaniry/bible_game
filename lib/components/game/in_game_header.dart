import 'package:bible_game/redux/game/header_view_model.dart';
import 'package:bible_game/redux/themes/themes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class InGameHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector(
      converter: GameHeaderViewModel.converter,
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, GameHeaderViewModel viewModel) {
    return _HeaderBuilder(viewModel);
  }
}

class _HeaderBuilder extends StatelessWidget {
  final GameHeaderViewModel _viewModel;

  _HeaderBuilder(this._viewModel);

  String get content {
    if (_viewModel.verse == null) {
      return "Words in word";
    }
    return "${_viewModel.verse.book} ${_viewModel.verse.chapter}:${_viewModel.verse.verse}";
  }

  @override
  Widget build(BuildContext context) {
    return _HeaderContainer(
      theme: _viewModel.theme,
      children: [
        _RoundedContainer(
          theme: _viewModel.theme,
          position: 'left',
          children: [
            Icon(
              Icons.view_carousel,
              color: _viewModel.theme.primaryLight,
              size: 22,
            ),
            Text(
              content,
              style: TextStyle(
                color: _viewModel.theme.neutral,
              ),
            )
          ],
        ),
        _RoundedContainer(
          theme: _viewModel.theme,
          position: 'right',
          children: [
            Text(
              "${_viewModel.inventory.money}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(
              Icons.monetization_on,
              color: _viewModel.theme.accentRight,
              size: 22,
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderContainer extends StatelessWidget {
  final List<Widget> children;
  final AppColorTheme theme;

  _HeaderContainer({
    @required this.children,
    @required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: theme.primary,
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 2,
              offset: Offset(0, 2),
            )
          ],
        ),
        padding: EdgeInsets.only(top: 8, bottom: 8, left: 5, right: 5),
        margin: EdgeInsets.only(bottom: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: children,
        ));
  }
}

class _RoundedContainer extends StatelessWidget {
  final List<Widget> children;
  final String position;
  final AppColorTheme theme;

  _RoundedContainer({
    @required this.children,
    @required this.position,
    @required this.theme,
  });

  EdgeInsets get _padding {
    if (position == 'left') {
      return const EdgeInsets.only(left: 2, top: 0, bottom: 0, right: 16);
    } else {
      return const EdgeInsets.only(left: 16, top: 0, bottom: 0, right: 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _padding,
      decoration: BoxDecoration(
          color: theme.primaryDark,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 2,
            )
          ],
          border: Border.all(
            color: theme.primaryLight,
            width: 2,
          )),
      child: Row(children: children),
    );
  }
}
