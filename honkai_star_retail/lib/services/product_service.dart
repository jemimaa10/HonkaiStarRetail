import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/product_model.dart';

class ProductService {
  static Future<List<ProductModel>> getAllProducts(String token) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/products'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic> rawData = body['data'];
      
      return rawData.map((item) => ProductModel.fromJson(item)).toList();
    } else {
      return [];
    }
  }

  static Future<bool> deleteProduct(String token, int id) async {
    final url = Uri.parse('${AppConstants.baseUrl}/products/$id');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error Delete: $e");
      return false;
    }
  }

  static Future<bool> addProduct(String token, Map<String, dynamic> data) async {
    final url = Uri.parse('${AppConstants.baseUrl}/products');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return response.statusCode == 201;
  }

  static Future<bool> updateProduct(String token, int id, Map<String, dynamic> data) async {
    final url = Uri.parse('${AppConstants.baseUrl}/products/$id');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }
}