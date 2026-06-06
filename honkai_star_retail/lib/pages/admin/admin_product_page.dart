import 'dart:ui' show ImageFilter; // WAJIB DIIMPORT UNTUK EFEK BLUR BACKGROUND
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/product_service.dart';
import '../../models/product_model.dart';
import 'admin_product_form.dart';

class AdminProductPage extends StatefulWidget {
  const AdminProductPage({super.key});

  @override
  State<AdminProductPage> createState() => _AdminProductPageState();
}

class _AdminProductPageState extends State<AdminProductPage> {
  int _selectedIndex = 0;

  List<Widget> _pages(String token) => [
        _buildProductList(token),
        _buildAdminProfile(),
      ];

  Widget _buildProductList(String token) {
    return FutureBuilder<List<ProductModel>>(
      future: ProductService.getAllProducts(token),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No product yet do be managed', style: TextStyle(color: Colors.white70)));
        }

        final products = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            
            return Card(
              // Diubah menjadi pekat semitransparan agar menyatu dengan latar belakang gambar
              color: const Color(0xFF151617).withOpacity(0.85),
              elevation: 0,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.white.withOpacity(0.08), width: 1), // Efek border neon tipis
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(10),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: product.imageUrl.isNotEmpty
                      ? Image.network(
                          product.imageUrl,
                          width: 55, height: 55, fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.white24),
                        )
                      : const Icon(Icons.image_not_supported, size: 50, color: Colors.white24),
                ),
                title: Text(
                  product.name, 
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
                ),
                subtitle: Text(
                  'Type: ${product.type} | Stock: ${product.stock}',
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_note, color: Colors.blueAccent, size: 28),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminProductForm(product: product)
                          ),
                        );
                        if (result == true) setState(() {});
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => _confirmDelete(token, product.id!),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAdminProfile() {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blueAccent, width: 2),
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFF1A1A1A),
              backgroundImage: user?['avatar_url'] != null 
                  ? NetworkImage(user!['avatar_url']) 
                  : null,
              child: user?['avatar_url'] == null 
                  ? const Icon(Icons.person, size: 60, color: Colors.white54) 
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            user?['name'] ?? 'Admin', 
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)
          ),
          Text(
            user?['email'] ?? '', 
            style: const TextStyle(color: Colors.white54, fontSize: 16)
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                authProvider.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
              icon: const Icon(Icons.logout),
              label: const Text('LOGOUT ADMIN', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent, 
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _confirmDelete(String token, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Erase product?', style: TextStyle(color: Colors.white)),
        content: const Text('Product data will be permanently erased', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Cancel', style: TextStyle(color: Colors.blueAccent))
          ),
          TextButton(
            onPressed: () async {
              await ProductService.deleteProduct(token, id);
              if (mounted) {
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final token = Provider.of<AuthProvider>(context).token;

    return Scaffold(
      backgroundColor: const Color(0xFF0C0C0D),
      extendBodyBehindAppBar: true, // 1. Membuat background naik melewati batas AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 2. Diubah ke transparan agar background tembus
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 80,
        title: Image.asset(
          'assets/images/logo_retail.png',
          height: 90,
          fit: BoxFit.contain,
        ),
      ),
      // 3. BACKGROUND STRUKTUR STACK GLOBAL DI ELEMENT UTAMA
      body: Stack(
        children: [
          // LAYER 1: Gambar Latar Belakang Baru Pilihanmu (.png)
          Positioned.fill(
            child: Image.network(
              'https://upload-os-bbs.hoyolab.com/upload/2023/01/28/17138284/85778450a3fbe5b61c4c0c2b47b82dc2_2925831787640733185.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),

          // LAYER 2: Efek Blur + Tint Kegelapan Semitransparan
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // Blur 5.0 biar gambar barumu tetep kelihatan manis siluetnya
              child: Container(
                color: Colors.black.withOpacity(0.55), 
              ),
            ),
          ),

          // LAYER 3: Konten Halaman Utama (Daftar Produk atau Profil)
          SafeArea(
            child: _pages(token!)[_selectedIndex],
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0 
        ? FloatingActionButton(
            backgroundColor: Colors.blueAccent,
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminProductForm()),
              );
              if (result == true) setState(() {});
            },
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          )
        : null,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0C0C0D).withOpacity(0.9), // Diberi opacity tipis biar menyatu
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Products'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}