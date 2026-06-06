import 'dart:ui' show ImageFilter; // WAJIB DIIMPORT UNTUK EFEK BLUR BACKGROUND
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
  bool _obscurePassword = true;

  bool validate() {
    if (nameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
      showError("All fields must be filled!");
      return false;
    }
    if (!emailController.text.contains('@')) {
      showError("Wrong email format!");
      return false;
    }
    if (passwordController.text.length < 6) {
      showError("Password must contain at least 6 characters");
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
          const SnackBar(content: Text("Registration successful! You can log in now"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        showError(result['message']);
      }
    } catch (e) {
      showError("Connection problem occured.");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0C0D),
      extendBodyBehindAppBar: true, // 1. Membuat background naik penuh menembus area AppBar atas
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 2. Diubah ke transparan agar gambar latar belakang tembus
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // 3. STRUKTUR STACK UNTUK LAYER BACKGROUND KOSMIK GLOBAL
      body: Stack(
        children: [
          // LAYER BACKGROUND 1: Gambar Latar Belakang Pilihanmu dari Hoyolab
          Positioned.fill(
            child: Image.network(
              'https://upload-os-bbs.hoyolab.com/upload/2023/01/28/17138284/85778450a3fbe5b61c4c0c2b47b82dc2_2925831787640733185.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),

          // LAYER BACKGROUND 2: Efek Keburaman (Blur) + Lapisan Transparan Gelap
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0), // Keburaman standar (8.0)
              child: Container(
                color: Colors.black.withOpacity(0.6), // Tint penggelap agar kontras tulisan form terjaga
              ),
            ),
          ),

          // LAYER 3: Konten Utama Form Register (Dibungkus SafeArea)
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logo_retail.png',
                      height: 130,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 35),
                    
                    // Input Nama Lengkap
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.person_outline, color: Colors.white70),
                        filled: true,
                        // Diubah ke opacity agar menyatu estetik dengan background blur
                        fillColor: const Color(0xFF1A1A1A).withOpacity(0.7),
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
                        fillColor: const Color(0xFF1A1A1A).withOpacity(0.7),
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

                    // Input Password
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
                        fillColor: const Color(0xFF1A1A1A).withOpacity(0.7),
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
                    
                    const SizedBox(height: 35),

                    // Tombol Submit Register
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
                        'Already have an account? Login here',
                        style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}