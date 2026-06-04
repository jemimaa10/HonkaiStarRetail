import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  // Inisialisasi GoogleSignIn
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '225073373774-03uaucl021s0u5es4etaavb7171ka2nv.apps.googleusercontent.com',
    scopes: ['email', 'profile', 'openid'],
  );
  
  bool isLoading = false;
  bool _obscurePassword = true; // State untuk kontrol melihat password

  bool validateInput() {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showError('Email dan Password tidak boleh kosong!');
      return false;
    }
    return true;
  }

  void showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> handleLogin() async {
    if (!validateInput()) return;
    setState(() => isLoading = true);

    try {
      final result = await AuthService.login(
        email: emailController.text,
        password: passwordController.text,
      );

      if (result['success']) {
        _onLoginSuccess(result['data']);
      } else {
        showError(result['message']);
      }
    } catch (e) {
      showError('Gagal terhubung ke server.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> handleGoogleSignIn() async {
    try {
      setState(() => isLoading = true);
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        if (mounted) setState(() => isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? tokenToSend = googleAuth.idToken ?? googleAuth.accessToken;

      if (tokenToSend == null) {
        showError("Gagal mendapatkan token.");
        return;
      }

      final result = await AuthService.googleLogin(idToken: tokenToSend);

      if (result['success']) {
        _onLoginSuccess(result['data']);
      } else {
        showError(result['message']);
      }
    } catch (error) {
      showError("Login Gagal: $error");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _onLoginSuccess(Map<String, dynamic> data) {
    Provider.of<AuthProvider>(context, listen: false).setAuth(
      newToken: data['token'],
      newUser: data['user'],
    );

    if (data['user']['role'] == 'admin') {
      Navigator.pushReplacementNamed(context, '/admin-home');
    } else {
      Navigator.pushReplacementNamed(context, '/market');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0C0D), // Tema gelap
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Menghilangkan tombol back jika ada
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. LOGO KUSTOM (Besar & Dominan)
              Image.asset(
                'assets/images/logo_retail.png',
                height: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 50),
              
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
              
              // Input Password dengan Tombol Mata
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
              const SizedBox(height: 30),
              
              // Tombol Login Utama
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 25,
                          width: 25,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'LOGIN', 
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)
                        ),
                ),
              ),

              const SizedBox(height: 20),
              const Text("OR", style: TextStyle(color: Colors.white54)),
              const SizedBox(height: 20),

              // Tombol Google (Aset Lokal)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : handleGoogleSignIn,
                  icon: Image.asset(
                    'assets/images/google_logo.png', // Menggunakan aset lokal
                    height: 24,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.login, color: Colors.white),
                  ),
                  label: const Text(
                    'Masuk dengan Google',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterPage()),
                  );
                },
                child: const Text(
                  'Belum punya akun? Daftar di sini',
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}