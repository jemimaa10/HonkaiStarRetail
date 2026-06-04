import 'package:flutter/material.dart';
import '../pages/user/market_page.dart';
import '../pages/user/cart_page.dart'; // IMPORT INI
// ... import lainnya

class AppRoutes {
  static const String market = '/market';
  static const String cart = '/cart'; // DEFINISIKAN STRINGNYA

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      '/market': (context) => const MarketPage(),
      '/cart': (context) => const CartPage(), // DAFTARKAN DI SINI
      // ... route lainnya
    };
  }
}