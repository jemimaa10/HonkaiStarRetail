import 'package:flutter/material.dart'; // WAJIB ADA
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
  Future<void> _refreshProducts() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final token = authProvider.token;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Star Rail Market'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProducts,
        child: token == null
            ? const Center(child: Text('Sesi berakhir'))
            : FutureBuilder<List<ProductModel>>(
                future: ProductService.getAllProducts(token),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Gagal memuat produk'));
                  }
                  
                  final products = snapshot.data ?? [];
                  return GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return ProductCard(
                        product: products[index],
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/product-detail',
                          arguments: products[index],
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}