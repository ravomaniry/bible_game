import 'package:bible_game/app/game/components/in_game_header.dart';
import 'package:bible_game/app/inventory/components/shop.dart';
import 'package:bible_game/app/inventory/view_model.dart';
import 'package:bible_game/app/texts.dart';
import 'package:bible_game/app/theme/themes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class Inventory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector(
      converter: InventoryViewModel.converter,
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, InventoryViewModel viewModel) {
    if (viewModel.state.isOpen) {
      return _InventoryContainer(
        theme: viewModel.theme,
        header: InGameHeader(),
        children: [
          _Header(viewModel.theme, viewModel.texts),
          Shop(
            state: viewModel.state,
            theme: viewModel.theme,
            buyBonus: viewModel.buyBonus,
          ),
          _Footer(
            theme: viewModel.theme,
            closeHandler: viewModel.closeDialog,
          ),
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }
}

class _InventoryContainer extends StatelessWidget {
  final AppColorTheme theme;
  final List<Widget> children;
  final Widget header;

  _InventoryContainer({
    @required this.theme,
    @required this.children,
    @required this.header,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        key: Key("inventoryDialog"),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(theme.background),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          children: [
            header,
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(
                top: 40,
                left: 20,
                right: 20,
              ),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: theme.neutral,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(160),
                      blurRadius: 3,
                      offset: Offset(1, 1),
                    )
                  ]),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: children,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final AppColorTheme _theme;
  final AppTexts _texts;

  _Header(this._theme, this._texts);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Text(
        _texts.bonus,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: _theme.accentLeft,
          shadows: [
            BoxShadow(
              color: _theme.primaryDark,
              blurRadius: 1,
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final Function() closeHandler;
  final AppColorTheme theme;

  _Footer({
    @required this.closeHandler,
    @required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: RaisedButton(
        color: theme.primary,
        key: Key("inventoryOkButton"),
        onPressed: closeHandler,
        child: Icon(
          Icons.thumb_up,
          color: theme.neutral,
        ),
      ),
    );
  }
}
