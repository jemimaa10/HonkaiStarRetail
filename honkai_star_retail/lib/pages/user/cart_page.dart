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

  // LOGIK FIX: Mengecek status success dari Service
  Future<void> _handleCheckout(String token) async {
    setState(() => isCheckingOut = true);

    try {
      final result = await CartService.checkout(token);
      
      if (mounted) {
        // CEK APAKAH BENAR-BENAR SUKSES (Bukan cuma dapet response)
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Checkout Berhasil!'), 
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          // Kembalikan 'true' agar MainNavigation refresh saldo & inventory
          Navigator.pop(context, true); 
        } else {
          // JIKA GAGAL (Contoh: Saldo Kurang atau Stok Habis)
          _showErrorDialog(result['message'] ?? 'Checkout Gagal');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isCheckingOut = false);
    }
  }

  // Dialog estetik untuk memberitahu jika saldo kurang/error
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text("Transaksi Ditolak", style: TextStyle(color: Colors.redAccent)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final token = authProvider.token;

    if (token == null) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: Text("Sesi habis", style: TextStyle(color: Colors.white))));
    }

    return Scaffold(
      backgroundColor: Colors.black, // Tema Gelap
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
        backgroundColor: const Color(0xFF0C0C0D),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: CartService.getCartItems(token),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Gagal mengambil data keranjang', style: TextStyle(color: Colors.white)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Keranjang kamu masih kosong', style: TextStyle(color: Colors.white54)));
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
                  padding: const EdgeInsets.all(10),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    double price = parseToDouble(item['price']);
                    int qty = int.tryParse(item['quantity'].toString()) ?? 0;
                    double subTotal = price * qty;

                    return Card(
                      color: const Color(0xFF1A1A1A),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: item['image_url'] != null && item['image_url'].toString().isNotEmpty
                              ? Image.network(item['image_url'], width: 50, height: 50, fit: BoxFit.cover, 
                                  errorBuilder: (context, e, s) => const Icon(Icons.broken_image, color: Colors.white24))
                              : const Icon(Icons.shopping_bag, color: Colors.blueAccent),
                        ),
                        title: Text(item['name'] ?? 'Produk', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text('$qty x ${price.toStringAsFixed(0)} Credits', style: const TextStyle(color: Colors.white70)),
                        trailing: Text(
                          subTotal.toStringAsFixed(0),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                decoration: const BoxDecoration(
                  color: Color(0xFF0C0C0D),
                  border: Border(top: BorderSide(color: Colors.white12)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Pembayaran:', style: TextStyle(fontSize: 16, color: Colors.white)),
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
                          backgroundColor: Colors.blueAccent, 
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