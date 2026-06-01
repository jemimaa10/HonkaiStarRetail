import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class InventoryService {
  static Future<List<dynamic>> getInventory(String token) async {
    final url = Uri.parse('${AppConstants.baseUrl}/inventory');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['inventory'];
      } else {
        throw Exception('Gagal mengambil inventory');
      }
    } catch (e) {
      throw Exception('Kesalahan koneksi');
    }
  }
}