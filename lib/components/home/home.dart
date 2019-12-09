import 'package:bible_game/components/loader.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/home/view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, HomeViewModel>(
      key: Key("home"),
      builder: _builder,
      converter: HomeViewModel.converter,
    );
  }

  Widget _builder(BuildContext context, HomeViewModel viewModel) {
    if (viewModel.isReady) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/forest.jpg'),
            ),
          ),
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                colors: [Colors.transparent, Color.fromARGB(160, 0, 0, 0)],
                radius: 0.8,
                stops: [0.8, 1],
              ),
            ),
            child: Column(
              children: <Widget>[
                Expanded(child: Text("Home")),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      _buildDummyBtn("Explorer", "goToExplorer", viewModel.goToExplorer),
                      _buildDummyBtn("Words in word", "goToWordsInWordBtn", viewModel.goToWordsInWord),
                      _buildDummyBtn("Inventory", "inventoryBtn", viewModel.openInventory),
                      _buildDummyBtn("Calculator", "goToCalculatorBtn", viewModel.goToCalculator),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }
    return Loader();
  }

  Widget _buildDummyBtn(String text, String key, Function() onPressed) {
    return Container(
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/wood_panel.png"),
        ),
      ),
      child: FlatButton(
        key: Key(key),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              BoxShadow(offset: Offset(1, 1), color: Colors.grey, blurRadius: 1),
            ],
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
