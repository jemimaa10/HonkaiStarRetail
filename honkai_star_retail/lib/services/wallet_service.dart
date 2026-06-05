import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class WalletService {
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
        return double.tryParse(data.toString()) ?? 0.0;
      }
      throw 'Failed to get balance amount (Status: ${response.statusCode})';
    } catch (e) {
      throw 'Connection error: $e';
    }
  }

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
      throw data['message'] ?? 'Failed to Top Up';
    } catch (e) {
      rethrow;
    }
  }

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
        
        if (decodedData == null) return [];

        if (decodedData is List) {
          return decodedData; 
        } else if (decodedData is Map) {
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
      print('Network Error in WalletService: $e');
      return [];
    }
  }
}