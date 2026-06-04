import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/product_service.dart';
import '../../models/product_model.dart';
import '../../widgets/product_card.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  // Key unik untuk memicu rebuild FutureBuilder secara paksa saat ditarik (Pull to Refresh)
  Key _refreshKey = UniqueKey();

  Future<void> _refreshProducts() async {
    setState(() {
      _refreshKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final token = authProvider.token;

    return Scaffold(
      backgroundColor: Colors.black, // Tema gelap sesuai Star Rail
      body: RefreshIndicator(
        onRefresh: _refreshProducts,
        color: Colors.blueAccent,
        child: token == null
            ? const Center(child: Text('Sesi berakhir, silakan login ulang', style: TextStyle(color: Colors.white)))
            : FutureBuilder<List<ProductModel>>(
                key: _refreshKey,
                future: ProductService.getAllProducts(token),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Gagal memuat produk', style: TextStyle(color: Colors.white)),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _refreshProducts,
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  final products = snapshot.data ?? [];
                  
                  if (products.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 200),
                        Center(child: Text('Tidak ada produk tersedia', style: TextStyle(color: Colors.white24))),
                      ],
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(), 
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,          // 2 Kolom
                      childAspectRatio: 0.82,     // DIPERKECIL: Angka lebih besar = Box lebih pendek
                      crossAxisSpacing: 14,       // Jarak horizontal antar box
                      mainAxisSpacing: 14,        // Jarak vertikal antar box
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(
                        product: product,
                        onTap: () async {
                          // Navigasi ke Detail
                          await Navigator.pushNamed(
                            context,
                            '/product-detail',
                            arguments: product,
                          );
                          // Refresh saat kembali untuk update stok
                          _refreshProducts();
                        },
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}