import 'package:bible_game/redux/words_in_word/view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final WordsInWordViewModel _viewModel;

  Header(this._viewModel);

  String get content {
    if (_viewModel.verse == null) {
      return "Words in word";
    }
    return "${_viewModel.verse.book} ${_viewModel.verse.chapter}:${_viewModel.verse.verse}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 224, 153, 60),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(100, 0, 0, 0),
            blurRadius: 0,
            offset: Offset(0, 2),
          )
        ],
      ),
      padding: EdgeInsets.only(top: 6, bottom: 6, left: 5, right: 5),
      margin: EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _RoundedContainer(
            position: 'left',
            children: [
              const Icon(
                Icons.view_carousel,
                color: Color.fromARGB(255, 224, 153, 60),
                size: 22,
              ),
              Text(
                content,
                style: const TextStyle(color: Colors.white),
              )
            ],
          ),
          _RoundedContainer(
            position: 'right',
            children: [
              Text(
                "${_viewModel.inventory.money}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(
                Icons.monetization_on,
                color: Color.fromARGB(255, 224, 153, 60),
                size: 22,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundedContainer extends StatelessWidget {
  final List<Widget> children;
  final String position;

  _RoundedContainer({@required this.children, @required this.position});

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
          color: const Color.fromARGB(255, 46, 17, 4),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 2,
            )
          ],
          border: Border.all(
            color: Color.fromARGB(255, 191, 118, 41),
            width: 2,
          )),
      child: Row(children: children),
    );
  }
}
