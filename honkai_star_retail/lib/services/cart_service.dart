import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class CartService {
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

      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'message': decoded['message'] ?? 'Successfully added to cart.',
      };
    } catch (e) {
      print("Error addToCart: $e");
      return {'success': false, 'message': 'Failed connecting to server'};
    }
  }

  // --- PERBAIKAN: Mengubah productId menjadi cartId agar sesuai router.put('/:id') ---
  static Future<bool> updateCartQuantity(String token, int cartId, int quantity) async {
    final url = Uri.parse('${AppConstants.baseUrl}/cart/$cartId');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'quantity': quantity}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error updateCartQuantity: $e");
      return false;
    }
  }

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

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': decoded['message'] ?? 'Checkout successful!',
        };
      } else {
        return {
          'success': false,
          'message': decoded['message'] ?? 'Checkout failed, please check your balance',
        };
      }
    } catch (e) {
      print("Error checkout: $e");
      return {'success': false, 'message': 'Connection error!'};
    }
  }
  
  // --- PERBAIKAN: Mengubah productId menjadi cartId agar sesuai router.delete('/:id') ---
  static Future<bool> removeFromCart(String token, int cartId) async {
    final url = Uri.parse('${AppConstants.baseUrl}/cart/$cartId');
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

  // --- PERBAIKAN: Alias menggunakan parameter cartId untuk cart_page.dart ---
  static Future<bool> deleteCartItem(String token, int cartId) async {
    return await removeFromCart(token, cartId);
  }
}