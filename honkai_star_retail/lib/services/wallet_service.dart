import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class WalletService {
  static Future<double> getBalance(String token) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/wallet'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return double.parse(jsonDecode(response.body)['balance'].toString());
    }
    throw Exception('Gagal mengambil saldo');
  }
  static Future<Map<String, dynamic>> topUp(String token) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/wallet/topup'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return jsonDecode(response.body);
  }
}