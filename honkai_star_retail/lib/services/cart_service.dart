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
        return jsonDecode(response.body)['data'];
      }
      return [];
    } catch (e) {
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
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'product_id': productId, 'quantity': quantity}),
    );
    return jsonDecode(response.body);
  }

  // 3. FITUR CHECKOUT (POST) - Ini yang tadi hilang
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

      return {
        'success': response.statusCode == 200,
        'message': jsonDecode(response.body)['message'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server'};
    }
  }
}