import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class CartService {
  // 1. Ambil Daftar Isi Keranjang (GET)
  static Future<List<dynamic>> getCartItems(String token) async {
    final url = Uri.parse('${AppConstants.baseUrl}/cart');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print("Error getCartItems: $e");
      return [];
    }
  }

  // 2. Tambah Barang ke Keranjang (POST)
  static Future<Map<String, dynamic>> addToCart({
    required String token,
    required int productId,
    required int quantity,
  }) async {
    final url = Uri.parse('${AppConstants.baseUrl}/cart');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'product_id': productId, 'quantity': quantity}),
      );

      final decoded = jsonDecode(response.body);

      // Pastikan sukses hanya jika status 200 atau 201
      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'message': decoded['message'] ?? 'Berhasil menambah ke keranjang',
      };
    } catch (e) {
      print("Error addToCart: $e");
      return {'success': false, 'message': 'Gagal terhubung ke server'};
    }
  }

  // 3. FITUR CHECKOUT (POST) - DIPERBAIKI
  static Future<Map<String, dynamic>> checkout(String token) async {
    final url = Uri.parse('${AppConstants.baseUrl}/cart/checkout');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final decoded = jsonDecode(response.body);

      // LOGIC PENTING:
      // Transaksi hanya sukses jika status code 200.
      // Jika saldo kurang, Backend biasanya kirim 400 (Bad Request) atau 402 (Payment Required).
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': decoded['message'] ?? 'Checkout berhasil!',
        };
      } else {
        // Jika gagal (saldo kurang, stok habis tiba-tiba, dll)
        // Ambil pesan asli dari backend (misal: "Saldo tidak cukup")
        return {
          'success': false,
          'message': decoded['message'] ?? 'Checkout gagal. Periksa saldo Anda.',
        };
      }
    } catch (e) {
      print("Error checkout: $e");
      return {'success': false, 'message': 'Terjadi kesalahan koneksi'};
    }
  }
  
  // 4. Hapus item dari keranjang (DELETE)
  static Future<bool> removeFromCart(String token, int productId) async {
    final url = Uri.parse('${AppConstants.baseUrl}/cart/$productId');
    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error removeFromCart: $e");
      return false;
    }
  }
}