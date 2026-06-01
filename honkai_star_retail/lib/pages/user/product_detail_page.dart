import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/cart_service.dart';
import '../../utils/constants.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;
  bool isAdding = false;

  Future<void> handleAddToCart(ProductModel product, String token) async {
    // 1. Tambahkan pengecekan ID agar tidak null
    if (product.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: ID Produk tidak ditemukan")),
      );
      return;
    }

    setState(() => isAdding = true);

    final result = await CartService.addToCart(
      token: token,
      productId: product.id!, // Gunakan ! karena kita sudah cek tidak null
      quantity: quantity,
    );

    if (mounted) {
      setState(() => isAdding = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data produk dari arguments
    final product = ModalRoute.of(context)!.settings.arguments as ProductModel;
    final token = Provider.of<AuthProvider>(context).token;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Produk')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2. Gunakan null-aware pada imageUrl
            Image.network(
              product.imageUrl,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              errorBuilder: (context, e, s) => const SizedBox(
                height: 300, 
                child: Center(child: Icon(Icons.broken_image, size: 100))
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(product.type, style: const TextStyle(color: Colors.blueAccent, fontSize: 16)),
                  const SizedBox(height: 20),
                  Text('${product.price.toStringAsFixed(0)} Credits', 
                    style: const TextStyle(fontSize: 24, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                  const Divider(height: 40),
                  const Text('Deskripsi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  // 3. Tambahkan penanganan deskripsi jika null
                  Text(
                    product.description ?? 'Tidak ada deskripsi.', 
                    style: const TextStyle(fontSize: 16, height: 1.5)
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      const Text('Stok:', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 10),
                      Text('${product.stock}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        onPressed: () => setState(() => quantity > 1 ? quantity-- : null),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('$quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        // Gunakan pengecekan stok agar quantity tidak melebihi stok tersedia
                        onPressed: () => setState(() => quantity < product.stock ? quantity++ : null),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          // Tambahkan pengecekan stok: Jika stok 0, tombol tidak bisa diklik
          onPressed: (isAdding || product.stock <= 0) 
              ? null 
              : () => handleAddToCart(product, token!),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 55),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
          ),
          child: isAdding 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
              : Text(product.stock > 0 ? 'TAMBAH KE KERANJANG' : 'STOK HABIS'),
        ),
      ),
    );
  }
}