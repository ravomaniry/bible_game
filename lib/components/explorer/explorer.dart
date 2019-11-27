import 'dart:convert';

import 'package:bible_game/components/loader.dart';
import 'package:bible_game/redux/app_state.dart';
import 'package:bible_game/redux/explorer/view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class Explorer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ExplorerViewModel>(
      key: Key("explorer"),
      builder: _builder,
      converter: ExplorerViewModel.converter,
    );
  }

  Widget _builder(BuildContext context, ExplorerViewModel viewModel) {
    if (viewModel.books == null) {
      return Loader();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Explorer"),
      ),
      body: Text(json.encode(viewModel.books)),
    );
  }
}
