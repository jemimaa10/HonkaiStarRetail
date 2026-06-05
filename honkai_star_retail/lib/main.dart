import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/cart_provider.dart';

import 'pages/auth/login_page.dart';
import 'pages/auth/register_page.dart';
import 'pages/user/main_navigation.dart';
import 'pages/user/product_detail_page.dart';
import 'pages/user/cart_page.dart';
import 'pages/user/wallet_page.dart';
import 'pages/user/inventory_page.dart';
import 'pages/admin/admin_product_page.dart';
import 'pages/admin/admin_product_form.dart';
import 'utils/theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/login', 
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        
        '/market': (context) => const MainNavigation(), 
        '/product-detail': (context) => const ProductDetailPage(),
        '/cart': (context) => const CartPage(),    
        '/wallet': (context) => const WalletPage(),  
        '/inventory': (context) => const InventoryPage(),
        
        '/admin-home': (context) => const AdminProductPage(),
        '/admin-product-form': (context) => const AdminProductForm(),
      },
    );
  }
}