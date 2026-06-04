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
  // Key unik untuk memicu rebuild FutureBuilder secara paksa
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

    return RefreshIndicator(
      onRefresh: _refreshProducts,
      child: token == null
          ? const Center(child: Text('Sesi berakhir, silakan login ulang'))
          : FutureBuilder<List<ProductModel>>(
              key: _refreshKey, // Menggunakan key agar UI refresh total saat ditarik
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
                        const Text('Gagal memuat produk'),
                        TextButton(
                          onPressed: _refreshProducts,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }
                
                final products = snapshot.data ?? [];
                
                if (products.isEmpty) {
                  return ListView( // Pakai ListView agar RefreshIndicator tetap bekerja
                    children: const [
                      SizedBox(height: 200),
                      Center(child: Text('Tidak ada produk tersedia')),
                    ],
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  physics: const AlwaysScrollableScrollPhysics(), 
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      onTap: () async {
                        // Tunggu hasil dari detail page (jika ada pembelian)
                        await Navigator.pushNamed(
                          context,
                          '/product-detail',
                          arguments: product,
                        );
                        // Refresh market saat kembali dari detail untuk update stok terbaru
                        _refreshProducts();
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}