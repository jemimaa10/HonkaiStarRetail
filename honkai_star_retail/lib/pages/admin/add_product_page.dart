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
  // Fungsi untuk menghapus produk
  Future<void> _deleteProduct(String token, int productId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Hapus Produk?', style: TextStyle(color: Colors.white)),
        content: const Text('Tindakan ini tidak bisa dibatalkan.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: const Text('Batal', style: TextStyle(color: Colors.blueAccent))
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Hapus', style: TextStyle(color: Colors.redAccent))
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Pastikan method deleteProduct sudah ada di ProductService kamu
      final success = await ProductService.deleteProduct(token, productId);
      if (success) {
        setState(() {}); // Refresh data setelah hapus
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Produk berhasil dihapus"), backgroundColor: Colors.green),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final token = authProvider.token;

    return Scaffold(
      backgroundColor: const Color(0xFF0C0C0D), // Background gelap
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C0C0D),
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 80, // Ukuran toolbar konsisten
        // GANTI TEKS DENGAN LOGO
        title: Image.asset(
          'assets/images/logo_retail.png',
          height: 90,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
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
            return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Belum ada produk.', style: TextStyle(color: Colors.white70)),
            );
          }

          final products = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                color: const Color(0xFF1A1A1A), // Card gelap
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: product.imageUrl != null 
                      ? Image.network(product.imageUrl!, width: 60, height: 60, fit: BoxFit.cover)
                      : const Icon(Icons.image_not_supported, color: Colors.white24),
                  ),
                  title: Text(
                    product.name,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      'Tipe: ${product.type} | Stok: ${product.stock}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tombol Edit
                      IconButton(
                        icon: const Icon(Icons.edit_note, color: Colors.blueAccent, size: 28),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminProductForm(product: product),
                            ),
                          );
                          if (result == true) setState(() {}); // Refresh jika ada perubahan
                        },
                      ),
                      // Tombol Hapus
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => _deleteProduct(token, product.id!),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      // Floating Action Button yang lebih keren
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminProductForm()),
          );
          if (result == true) setState(() {}); // Refresh data setelah tambah
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}