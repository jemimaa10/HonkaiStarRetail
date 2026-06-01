import 'package:flutter/material.dart';

class WalletProvider extends ChangeNotifier {
  double _balance = 0;
  double get balance => _balance;

  void updateBalance(double newBalance) {
    _balance = newBalance;
    notifyListeners();
  }
}