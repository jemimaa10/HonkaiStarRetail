import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/product_service.dart';
import '../../models/product_model.dart';

class AdminProductPage extends StatefulWidget {
  const AdminProductPage({super.key});

  @override
  State<AdminProductPage> createState() => _AdminProductPageState();
}

class _AdminProductPageState extends State<AdminProductPage> {
  // Fungsi untuk menghapus produk
  Future<void> _deleteProduct(String token, int productId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk?'),
        content: const Text('Tindakan ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      // Panggil service delete (Pastikan kamu sudah buat method delete di ProductService)
      // await ProductService.deleteProduct(token, productId);
      setState(() {}); // Refresh data
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final token = authProvider.token;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel - Stok Barang'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: ProductService.getAllProducts(token!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada produk.'));
          }

          final products = snapshot.data!;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: ListTile(
                  leading: product.imageUrl != null 
                    ? Image.network(product.imageUrl!, width: 50, fit: BoxFit.cover)
                    : const Icon(Icons.image_not_supported),
                  title: Text(product.name),
                  subtitle: Text('Stok: ${product.stock} | Harga: ${product.price}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // Navigasi ke form edit
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProduct(token, product.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigasi ke halaman tambah produk
          // Navigator.pushNamed(context, '/admin-add-product');
        },
        label: const Text('Tambah Produk'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}