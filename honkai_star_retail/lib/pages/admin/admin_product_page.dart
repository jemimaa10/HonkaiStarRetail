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

  // Menggunakan getter agar token selalu terbaru saat build
  List<Widget> _pages(String token) => [
        _buildProductList(token),
        _buildAdminProfile(),
      ];

  Widget _buildProductList(String token) {
    return FutureBuilder<List<ProductModel>>(
      future: ProductService.getAllProducts(token),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Belum ada produk untuk dikelola.'));
        }

        final products = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: product.imageUrl.isNotEmpty
                      ? Image.network(
                          product.imageUrl,
                          width: 50, height: 50, fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                        )
                      : const Icon(Icons.image_not_supported, size: 50),
                ),
                title: Text(
                  product.name, 
                  style: const TextStyle(fontWeight: FontWeight.bold)
                ),
                subtitle: Text('Tipe: ${product.type} | Stok: ${product.stock}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
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
                      icon: const Icon(Icons.delete, color: Colors.red),
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
          CircleAvatar(
            radius: 50,
            backgroundImage: user?['avatar_url'] != null 
                ? NetworkImage(user!['avatar_url']) 
                : null,
            child: user?['avatar_url'] == null ? const Icon(Icons.person, size: 50) : null,
          ),
          const SizedBox(height: 20),
          Text(user?['name'] ?? 'Admin', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(user?['email'] ?? '', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              authProvider.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout Admin'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, 
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
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
        title: const Text('Hapus Produk?'),
        content: const Text('Data produk akan dihapus secara permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              await ProductService.deleteProduct(token, id);
              if (mounted) {
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final token = Provider.of<AuthProvider>(context).token;

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Daftar Produk Admin' : 'Profil Admin'),
        centerTitle: true,
      ),
      body: _pages(token!)[_selectedIndex],
      floatingActionButton: _selectedIndex == 0 
        ? FloatingActionButton(
            onPressed: () async {
              // PERBAIKAN: Pastikan memanggil tanpa 'const'
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminProductForm()),
              );
              if (result == true) setState(() {});
            },
            child: const Icon(Icons.add),
          )
        : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Products'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}