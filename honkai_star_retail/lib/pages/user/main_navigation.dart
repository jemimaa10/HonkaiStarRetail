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

  // 1. Tambahkan dua GlobalKey: satu untuk Inventory, satu untuk Wallet
  final GlobalKey<InventoryPageState> _inventoryKey = GlobalKey<InventoryPageState>();
  final GlobalKey<WalletPageState> _walletKey = GlobalKey<WalletPageState>();

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // 2. Pasang kedua Key ke halaman masing-masing
    _pages = [
      const MarketPage(),
      InventoryPage(key: _inventoryKey), 
      WalletPage(key: _walletKey), // PENTING: Pasang key wallet di sini
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Star Rail Retail', 
          style: TextStyle(fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () async {
              final result = await Navigator.pushNamed(context, '/cart');

              if (result == true) {
                // 3. PAKSA REFRESH KEDUANYA: Barang & Saldo
                _inventoryKey.currentState?.fetchInventory();
                _walletKey.currentState?.fetchWallet();

                // Pindah tab ke Inventory agar user langsung lihat hasilnya
                setState(() {
                  _selectedIndex = 1;
                });
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, 
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
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