import 'dart:ui' show ImageFilter; // WAJIB DIIMPORT UNTUK EFEK BLUR BACKGROUND
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
  Key _refreshKey = UniqueKey(); // Digunakan untuk refresh data setelah update/delete

  // Simpan data local snapshot agar bisa dimanipulasi secara instan (Optimistic UI)
  List<dynamic>? _localCartItems;

  double parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  // Fungsi memicu pembaruan/refresh UI local
  void _triggerRefresh() {
    setState(() {
      _localCartItems = null; // Reset local data agar mengambil yang terbaru dari server
      _refreshKey = UniqueKey();
    });
  }

  // --- AKSI UPDATE KUANTITAS (TAMBAH / KURANG) ---
  // PERBAIKAN: Mengganti productId menjadi cartId agar sinkron dengan backend
  Future<void> _updateQuantity(String token, int cartId, int newQuantity, int index) async {
    if (cartId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Cart ID'), backgroundColor: Colors.red),
      );
      return;
    }

    if (newQuantity < 1) {
      _handleDeleteItem(token, cartId);
      return;
    }
    
    // Trik Optimistic UI: Ubah angka di layar secara instan sebelum menembak API backend
    setState(() {
      if (_localCartItems != null && _localCartItems!.length > index) {
        _localCartItems![index]['quantity'] = newQuantity;
      }
    });
    
    // Kirim update ke backend menggunakan cartId
    final success = await CartService.updateCartQuantity(token, cartId, newQuantity);
    
    // Jika gagal, kembalikan data ke versi asli server demi sinkronisasi stok
    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update quantity on server'), backgroundColor: Colors.orange),
        );
      }
      _triggerRefresh();
    } else {
      // Jika sukses, tetep panggil refresh untuk memastikan kalkulasi harga global akurat dengan server
      _triggerRefresh();
    }
  }

  // --- AKSI HAPUS ITEM DARI KERANJANG ---
  // PERBAIKAN: Mengganti productId menjadi cartId
  Future<void> _handleDeleteItem(String token, int cartId) async {
    if (cartId == 0) return;

    final success = await CartService.deleteCartItem(token, cartId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item removed from cart.'), backgroundColor: Colors.redAccent),
      );
      _triggerRefresh();
    }
  }

  Future<void> _handleCheckout(String token) async {
    setState(() => isCheckingOut = true);

    try {
      final result = await CartService.checkout(token);
      
      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Checkout Success!'), 
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          Navigator.pop(context, true); 
        } else {
          _showErrorDialog(result['message'] ?? 'Checkout Failed');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error occurred: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isCheckingOut = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text("Transaction rejected", style: TextStyle(color: Colors.redAccent)),
        content: Text(message, style: const TextStyle(color: const Color(0xFFFFFFFF))),
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
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: Text("Session ended!", style: TextStyle(color: Colors.white))));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0C0C0D),
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: const Text('Shopping Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, 
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://upload-os-bbs.hoyolab.com/upload/2023/01/28/17138284/85778450a3fbe5b61c4c0c2b47b82dc2_2925831787640733185.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
              child: Container(color: Colors.black.withOpacity(0.6)),
            ),
          ),
          SafeArea(
            child: FutureBuilder<List<dynamic>>(
              key: _refreshKey, 
              future: CartService.getCartItems(token),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && _localCartItems == null) {
                  return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
                }
                if (snapshot.hasError && _localCartItems == null) {
                  return const Center(child: Text('Failed to get cart items!', style: TextStyle(color: Colors.white)));
                }
                
                // Inisialisasi local data dari server snapshot jika belum terisi
                if (snapshot.hasData && _localCartItems == null) {
                  _localCartItems = List<dynamic>.from(snapshot.data!);
                }

                if (_localCartItems == null || _localCartItems!.isEmpty) {
                  return const Center(child: Text('Your cart is still empty!', style: TextStyle(color: Colors.white54)));
                }

                final cartItems = _localCartItems!;
                
                double totalGlobal = cartItems.fold(0, (sum, item) {
                  double price = parseToDouble(item['price']);
                  int qty = int.tryParse(item['quantity'].toString()) ?? 0;
                  return sum + (price * qty);
                });

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          double price = parseToDouble(item['price']);
                          int qty = int.tryParse(item['quantity'].toString()) ?? 0;
                          double subTotal = price * qty;
                          
                          // PERBAIKAN UTAMA: Ambil item['id'] yang merujuk pada cart.id di database backend kamu
                          int cartId = int.tryParse(item['id']?.toString() ?? '') ?? 0;

                          return Card(
                            color: const Color(0xFF151617).withOpacity(0.85),
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.white.withOpacity(0.08)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: item['image_url'] != null && item['image_url'].toString().isNotEmpty
                                        ? Image.network(item['image_url'], width: 55, height: 55, fit: BoxFit.cover, 
                                            errorBuilder: (context, e, s) => const Icon(Icons.broken_image, color: Colors.white24))
                                        : const Icon(Icons.shopping_bag, color: Colors.blueAccent, size: 55),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['name'] ?? 'Product', 
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$qty x ${price.toStringAsFixed(0)} Credits', 
                                          style: const TextStyle(color: Colors.white70, fontSize: 12)
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        subTotal.toStringAsFixed(0),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blueAccent),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // PERBAIKAN: Melemparkan variabel cartId (bukan productId)
                                          _buildQtyActionButton(Icons.remove, () => _updateQuantity(token, cartId, qty - 1, index)),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                            child: Text(
                                              '$qty',
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                            ),
                                          ),
                                          // PERBAIKAN: Melemparkan variabel cartId (bukan productId)
                                          _buildQtyActionButton(Icons.add, () => _updateQuantity(token, cartId, qty + 1, index)),
                                          const SizedBox(width: 12),
                                          // PERBAIKAN: Melemparkan variabel cartId (bukan productId)
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                                            onPressed: () => _handleDeleteItem(token, cartId),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C0C0D).withOpacity(0.9),
                        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total payment:', style: TextStyle(fontSize: 15, color: Colors.white70)),
                              Text(
                                '${totalGlobal.toStringAsFixed(0)} Credits', 
                                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.blueAccent)
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
                                : const Text('CHECKOUT NOW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyActionButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white30),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: Colors.white, size: 14),
      ),
    );
  }
}