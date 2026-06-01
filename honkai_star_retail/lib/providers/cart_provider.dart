import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  int _itemCount = 0;
  int get itemCount => _itemCount;

  void updateCount(int count) {
    _itemCount = count;
    notifyListeners();
  }
}