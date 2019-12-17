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
    return "${_viewModel.verse.book} ${_viewModel.verse.chapter}: ${_viewModel.verse.verse}";
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
          Container(
            padding: EdgeInsets.only(left: 2, right: 6, top: 4, bottom: 6),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 46, 17, 4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
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
          ),
          Container(
            child: Container(
              padding: EdgeInsets.only(left: 16, top: 2, bottom: 2, right: 2),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 46, 17, 4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
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
            ),
          ),
        ],
      ),
    );
  }
}
