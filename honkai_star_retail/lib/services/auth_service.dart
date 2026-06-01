import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart'; // Tambahkan import ini
import '../utils/constants.dart';

class AuthService {
  // Inisialisasi GoogleSignIn (Pastikan plugin sudah ada di pubspec.yaml)
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // =====================================================
  // 1. LOGIN MANUAL (Email & Password)
  // =====================================================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${AppConstants.baseUrl}/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login gagal',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
      };
    }
  }

  // =====================================================
  // 2. REGISTER
  // =====================================================
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${AppConstants.baseUrl}/auth/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registrasi gagal',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server.',
      };
    }
  }

  // =====================================================
  // 3. GOOGLE LOGIN (Kirim idToken untuk Keamanan)
  // =====================================================
  
  // PERBAIKAN: Gunakan idToken alih-alih data mentah
  static Future<Map<String, dynamic>> googleLogin({
    required String idToken,
  }) async {
    final url = Uri.parse('${AppConstants.baseUrl}/auth/google-login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': idToken, // Kirim idToken agar diverifikasi Backend
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login Google gagal',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal melakukan otentikasi Google.',
      };
    }
  }

  static Future<Map<String, dynamic>> handleGoogleSignIn() async {
    try {
      // 1. Munculkan Popup Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return {'success': false, 'message': 'Sign-in cancelled by user'};
      }

      // 2. Ambil Authentication (untuk mendapatkan idToken)
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Kirim idToken ke backend
      // Ini jauh lebih aman daripada mengirim name/email langsung
      return await googleLogin(
        idToken: googleAuth.idToken ?? "",
      );
      
    } catch (e) {
      return {'success': false, 'message': 'Google Error: $e'};
    }
  }
}