import 'dart:ui' show ImageFilter; 
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
      // 1. KUNCI UTAMA: Diubah ke transparan agar gambar dari MainNavigation tembus
      backgroundColor: Colors.transparent, 
      body: RefreshIndicator(
        onRefresh: _refreshProducts,
        color: Colors.blueAccent,
        child: token == null
            ? const Center(child: Text('Session ended, please login again', style: TextStyle(color: Colors.white)))
            : FutureBuilder<List<ProductModel>>(
                key: _refreshKey,
                future: ProductService.getAllProducts(token),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
                  }
                  
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Failed to load products', style: TextStyle(color: Colors.white)),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                            onPressed: _refreshProducts,
                            child: const Text('Try again', style: TextStyle(color: Colors.white)),
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
                        Center(child: Text('No products available', style: TextStyle(color: Colors.white24))),
                      ],
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(), 
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,          
                      childAspectRatio: 0.82,     
                      crossAxisSpacing: 14,       
                      mainAxisSpacing: 14,       
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(
                        product: product,
                        onTap: () async {
                          await Navigator.pushNamed(
                            context,
                            '/product-detail',
                            arguments: product,
                          );
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