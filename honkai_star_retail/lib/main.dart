import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import Providers
import 'providers/auth_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/cart_provider.dart';

// Import Pages
import 'pages/auth/login_page.dart';
import 'pages/auth/register_page.dart';
import 'pages/user/main_navigation.dart';
import 'pages/user/product_detail_page.dart';
import 'pages/user/cart_page.dart'; // Tambahkan ini
import 'pages/user/wallet_page.dart'; // Tambahkan ini
import 'pages/user/inventory_page.dart'; // Tambahkan ini
import 'pages/admin/admin_product_page.dart';
import 'pages/admin/admin_product_form.dart'; // Tambahkan ini
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
      // Gunakan initialRoute jika rute sudah didefinisikan di bawah
      initialRoute: '/login', 
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        
        // --- USER ROUTES ---
        '/market': (context) => const MainNavigation(), 
        '/product-detail': (context) => const ProductDetailPage(),
        '/cart': (context) => const CartPage(),      // <--- DAFTARKAN INI
        '/wallet': (context) => const WalletPage(),  // <--- DAFTARKAN INI
        '/inventory': (context) => const InventoryPage(), // <--- DAFTARKAN INI
        
        // --- ADMIN ROUTES ---
        '/admin-home': (context) => const AdminProductPage(),
        '/admin-product-form': (context) => const AdminProductForm(), // <--- DAFTARKAN INIIII
      },
    );
  }
}