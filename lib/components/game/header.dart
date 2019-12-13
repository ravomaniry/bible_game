import 'package:bible_game/redux/game/view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomeHeader extends StatelessWidget {
  final GameViewModel _viewModel;

  HomeHeader(this._viewModel);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(0),
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.fitWidth,
          image: AssetImage("assets/images/wood_panel.png"),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          HomeButton(
            Icons.remove_red_eye,
            "goToExplorer",
            _viewModel.goToExplorer,
          ),
          HomeButton(
            Icons.add_shopping_cart,
            "inventoryBtn",
            _viewModel.openInventory,
          ),
          HomeButton(
            Icons.videogame_asset,
            "goToWordsInWordBtn",
            _viewModel.goToWordsInWord,
          ),
        ],
      ),
    );
  }
}

class HomeButton extends StatelessWidget {
  final IconData _iconData;
  final String _key;
  final Function() _onPressed;

  HomeButton(this._iconData, this._key, this._onPressed);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: Key(_key),
      onPressed: _onPressed,
      icon: Icon(_iconData),
    );
  }
}
