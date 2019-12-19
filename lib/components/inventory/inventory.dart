import 'package:bible_game/components/inventory/footer.dart';
import 'package:bible_game/components/inventory/header.dart';
import 'package:bible_game/components/inventory/shop.dart';
import 'package:bible_game/redux/inventory/view_model.dart';
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
      return Container(
        decoration: BoxDecoration(color: Color.fromARGB(140, 0, 0, 0)),
        child: Dialog(
          key: Key("inventoryDialog"),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Header(),
              Shop(
                state: viewModel.state,
                theme: viewModel.theme,
                buyBonus: viewModel.buyBonus,
              ),
              Footer(viewModel.closeDialog),
            ],
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
