import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/cart_service.dart';
import '../../utils/constants.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool isCheckingOut = false;

  // Fungsi konversi agar aman dari error String vs Num
  double parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
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
        future: CartService.getCartItems(token),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Gagal mengambil data'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Keranjang kosong'));
          }

          final cartItems = snapshot.data!;
          
          // Hitung Total Keseluruhan dengan aman
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
                    
                    // Parsing data per item
                    double price = parseToDouble(item['price']);
                    int qty = int.tryParse(item['quantity'].toString()) ?? 0;
                    double subTotal = price * qty;

                    return ListTile(
                      leading: item['image_url'] != null 
                        ? Image.network(item['image_url'], width: 50, height: 50, fit: BoxFit.cover)
                        : const Icon(Icons.shopping_bag),
                      title: Text(item['name'] ?? 'Produk'),
                      // Menampilkan harga satuan dengan rapi
                      subtitle: Text('$qty x ${price.toStringAsFixed(0)} Credits'),
                      // Menampilkan total per item di sebelah kanan
                      trailing: Text(
                        '${subTotal.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                decoration: const BoxDecoration(
                  color: Color(0xFF121212),
                  border: Border(top: BorderSide(color: Colors.white12)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:', style: TextStyle(fontSize: 18, color: Colors.white)),
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
                        onPressed: isCheckingOut ? null : () {
                          setState(() => isCheckingOut = true);
                          CartService.checkout(token).then((val) {
                             if (mounted) setState(() => isCheckingOut = false);
                             // Navigasi atau SnackBar sukses bisa ditambahkan di sini
                          });
                        },
                        child: isCheckingOut 
                          ? const SizedBox(
                              height: 20, 
                              width: 20, 
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