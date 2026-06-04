import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  bool isLoading = false;
  bool _obscurePassword = true; // State untuk toggle mata password

  // Validasi Input
  bool validate() {
    if (nameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
      showError("Semua field wajib diisi!");
      return false;
    }
    if (!emailController.text.contains('@')) {
      showError("Format email salah!");
      return false;
    }
    if (passwordController.text.length < 6) {
      showError("Password minimal 6 karakter!");
      return false;
    }
    return true;
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  Future<void> handleRegister() async {
    if (!validate()) return;

    setState(() => isLoading = true);

    try {
      final result = await AuthService.register(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
      );

      if (result['success']) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registrasi Berhasil! Silakan Login."), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Kembali ke halaman login
      } else {
        showError(result['message']);
      }
    } catch (e) {
      showError("Terjadi kesalahan koneksi.");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0C0D), // Background gelap senada login
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // Tombol back jadi putih
        // Judul 'Trailblazer Registration' dihapus agar clean
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // 1. Logo Kustom (Besar seperti di Login Page)
            Image.asset(
              'assets/images/logo_retail.png',
              height: 150,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 40),
            
            // Input Nama Lengkap
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.person_outline, color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.blueAccent),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Input Email
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Email Address',
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.email_outlined, color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.blueAccent),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 15),

            // Input Password dengan Fitur Mata
            TextField(
              controller: passwordController,
              obscureText: _obscurePassword,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white54,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.blueAccent),
                ),
              ),
            ),
            
            const SizedBox(height: 40),

            // 2. Tombol Register (Teks putih tebal)
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 25,
                        width: 25,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'CREATE ACCOUNT',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Tombol Kembali ke Login
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Sudah punya akun? Login di sini',
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}