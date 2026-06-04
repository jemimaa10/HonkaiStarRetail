import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class WalletService {
  // 1. Ambil Saldo
  static Future<double> getBalance(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/wallet/balance'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('balance')) {
          return double.tryParse(data['balance'].toString()) ?? 0.0;
        }
        // Jika response langsung berupa angka/string
        return double.tryParse(data.toString()) ?? 0.0;
      }
      throw 'Gagal mengambil saldo (Status: ${response.statusCode})';
    } catch (e) {
      throw 'Koneksi error: $e';
    }
  }

  // 2. Top Up
  static Future<Map<String, dynamic>> topUp(String token) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/wallet/topup'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      }
      throw data['message'] ?? 'Gagal melakukan Top Up';
    } catch (e) {
      rethrow;
    }
  }

  // 3. Ambil Riwayat Transaksi (Lebih Stabil)
  static Future<List<dynamic>> getTransactions(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/wallet/transactions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);
        
        // Cek jika decodedData null
        if (decodedData == null) return [];

        // Logika Fleksibel untuk berbagai format JSON
        if (decodedData is List) {
          return decodedData; 
        } else if (decodedData is Map) {
          // Cek beberapa key yang umum digunakan oleh library backend (Sequelize/Knex/Raw)
          if (decodedData.containsKey('data')) return decodedData['data'] as List<dynamic>;
          if (decodedData.containsKey('rows')) return decodedData['rows'] as List<dynamic>;
          if (decodedData.containsKey('results')) return decodedData['results'] as List<dynamic>;
        }
        return [];
      } else {
        print('Backend Error ${response.statusCode}: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Network Error di WalletService: $e');
      return []; // Mengembalikan list kosong agar UI tidak crash
    }
  }
}