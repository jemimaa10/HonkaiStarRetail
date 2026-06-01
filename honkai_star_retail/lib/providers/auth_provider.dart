import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {

  String? token;

  Map<String, dynamic>? user;

  bool get isLoggedIn => token != null;

  // save login
  void setAuth({
    required String newToken,
    required Map<String, dynamic> newUser,
  }) {

    token = newToken;

    user = newUser;

    notifyListeners();
  }

  // logout
  void logout() {

    token = null;

    user = null;

    notifyListeners();
  }
}