import 'package:bible_game/redux/app_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:bible_game/redux/calculator/view_model.dart';

class Calculator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, CalculatorViewModel>(
      key: Key("calculator"),
      converter: CalculatorViewModel.converter,
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, CalculatorViewModel viewModel) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calculator"),
      ),
      backgroundColor: Color.fromARGB(255, 250, 250, 250),
      body: Column(
        children: [
          _Display(viewModel),
          _Keyboard(viewModel),
        ],
      ),
    );
  }
}

class _Display extends StatelessWidget {
  final CalculatorViewModel _viewModel;

  _Display(this._viewModel);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerRight,
            child: Text(
              _viewModel.a.toString(),
              key: Key("a"),
              style: TextStyle(
                fontSize: 12,
                color: Color.fromARGB(200, 0, 0, 0),
              ),
            ),
          ),
          Text(
            _viewModel.operator,
            key: Key("operator"),
            style: TextStyle(fontSize: 12),
          ),
          Container(
            child: Text(
              _viewModel.output,
              key: Key("output"),
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            alignment: Alignment.centerRight,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          ),
        ],
      ),
    );
  }
}

class _Keyboard extends StatelessWidget {
  final CalculatorViewModel _viewModel;

  _Keyboard(this._viewModel);

  Widget _buildButton(String text) {
    return Expanded(
      child: OutlineButton(
        key: Key(text),
        padding: EdgeInsets.all(20),
        child: Text(text, style: TextStyle(fontSize: 18)),
        onPressed: () => _viewModel.handleInput(text),
        color: Colors.amber,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Column(
            children: [
              _KeysRow(["7", "8", "9", "/"], _viewModel),
              _KeysRow(["4", "5", "6", "*"], _viewModel),
              _KeysRow(["1", "2", "3", "-"], _viewModel),
              _KeysRow([".", "0", "00", "+"], _viewModel),
              _KeysRow(["CLEAR", "DEL", "="], _viewModel),
            ],
          ),
        ],
      ),
    );
  }
}

class _KeysRow extends StatelessWidget {
  final List<String> _keys;
  final CalculatorViewModel _viewModel;

  _KeysRow(this._keys, this._viewModel);

  Widget _buildButton(String text) {
    return Expanded(
      child: OutlineButton(
        key: Key(text),
        padding: EdgeInsets.all(20),
        child: Text(text, style: TextStyle(fontSize: 18)),
        onPressed: () => _viewModel.handleInput(text),
        color: Colors.amber,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _keys.map(_buildButton).toList(),
    );
  }
}
