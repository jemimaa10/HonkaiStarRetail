import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import Providers
import 'providers/auth_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/cart_provider.dart';

// Import Pages
import 'pages/auth/login_page.dart';
import 'pages/auth/register_page.dart';
import 'pages/user/main_navigation.dart'; // <--- PASTIKAN BARIS INI ADA
import 'pages/user/product_detail_page.dart';
import 'pages/admin/admin_product_page.dart';
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
      home: const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/market': (context) => const MainNavigation(), // Rute utama ke Navbar
        '/product-detail': (context) => const ProductDetailPage(),
        '/admin-home': (context) => const AdminProductPage(),
      },
    );
  }
}