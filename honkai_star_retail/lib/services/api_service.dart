import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/product_model.dart';

class ApiService {
  static Future<List<ProductModel>> fetchProducts(String token) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/products'),
      headers: {
        'Authorization': 'Bearer $token', // Verifikasi bearer token [cite: 57]
      },
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body)['data'];
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil produk');
    }
  }
}