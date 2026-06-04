import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/cart_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool isCheckingOut = false;

  double parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  // Fungsi Checkout yang sudah diperbaiki
  Future<void> _handleCheckout(String token) async {
    setState(() => isCheckingOut = true);

    try {
      final response = await CartService.checkout(token);
      
      if (mounted) {
        // Asumsi backend mengembalikan success boolean atau status 200
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Checkout Berhasil!'), backgroundColor: Colors.green),
        );

        // KUNCI UTAMA: Mengirimkan nilai 'true' saat kembali ke MainNavigation
        // agar tab Inventory otomatis refresh datanya.
        Navigator.pop(context, true); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal Checkout: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isCheckingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final token = authProvider.token;

    if (token == null) {
      return const Scaffold(body: Center(child: Text("Sesi habis")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang Belanja')),
      body: FutureBuilder<List<dynamic>>(
        // Gunakan future agar data selalu fresh saat halaman dibuka
        future: CartService.getCartItems(token),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Gagal mengambil data keranjang'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Keranjang kamu masih kosong'));
          }

          final cartItems = snapshot.data!;
          
          double totalGlobal = cartItems.fold(0, (sum, item) {
            double price = parseToDouble(item['price']);
            int qty = int.tryParse(item['quantity'].toString()) ?? 0;
            return sum + (price * qty);
          });

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    double price = parseToDouble(item['price']);
                    int qty = int.tryParse(item['quantity'].toString()) ?? 0;
                    double subTotal = price * qty;

                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: item['image_url'] != null && item['image_url'].toString().isNotEmpty
                            ? Image.network(item['image_url'], width: 50, height: 50, fit: BoxFit.cover, 
                                errorBuilder: (context, e, s) => const Icon(Icons.broken_image))
                            : const Icon(Icons.shopping_bag),
                      ),
                      title: Text(item['name'] ?? 'Produk'),
                      subtitle: Text('$qty x ${price.toStringAsFixed(0)} Credits'),
                      trailing: Text(
                        '${subTotal.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    );
                  },
                ),
              ),
              
              // Bottom Section untuk Total & Button
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: const Border(top: BorderSide(color: Colors.white12)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, -5))
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Pembayaran:', style: TextStyle(fontSize: 16)),
                        Text(
                          '${totalGlobal.toStringAsFixed(0)} Credits', 
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, 
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: isCheckingOut ? null : () => _handleCheckout(token),
                        child: isCheckingOut 
                          ? const SizedBox(
                              height: 24, 
                              width: 24, 
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            )
                          : const Text('CHECKOUT SEKARANG', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}