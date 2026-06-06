import 'dart:ui' show ImageFilter; 
import 'package:flutter/material.dart';
import 'market_page.dart';
import 'inventory_page.dart';
import 'wallet_page.dart';
import 'profile_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final GlobalKey<InventoryPageState> _inventoryKey = GlobalKey<InventoryPageState>();
  final GlobalKey<WalletPageState> _walletKey = GlobalKey<WalletPageState>();

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const MarketPage(),
      InventoryPage(key: _inventoryKey), 
      WalletPage(key: _walletKey),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0C0D),
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 80, 
        
        title: Container(
          margin: const EdgeInsets.only(top: 10),
          child: Image.asset(
            'assets/images/logo_retail.png',
            height: 90,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Text(
                "STAR RETAIL",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              );
            },
          ),
        ),
        
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 28),
              onPressed: () async {
                final result = await Navigator.pushNamed(context, '/cart');

                if (result == true) {
                  _inventoryKey.currentState?.fetchInventory();
                  _walletKey.currentState?.fetchWallet();

                  setState(() {
                    _selectedIndex = 1;
                  });
                }
              },
            ),
          ),
        ],
      ),

      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://upload-os-bbs.hoyolab.com/upload/2023/01/28/17138284/85778450a3fbe5b61c4c0c2b47b82dc2_2925831787640733185.png', // Samakan atau sesuaikan dengan tema login
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),

          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Blur sedikit lebih tinggi untuk kenyamanan baca data
              child: Container(
                color: Colors.black.withOpacity(0.55), // Ditambah sedikit opacity agar item list/grid lebih terbaca
              ),
            ),
          ),

          SafeArea(
            bottom: false, // Biarkan konten meluncur ke bawah menembus navbar
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0C0C0D).withOpacity(0.9), // Sedikit transparan agar blend dengan background
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            activeIcon: Icon(Icons.storefront_sharp),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}