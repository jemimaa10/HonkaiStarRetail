import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';

import '../user/main_navigation.dart';
import '../admin/admin_product_page.dart';
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

  bool validateInput() {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showError('Email dan Password tidak boleh kosong!');
      return false;
    }
    if (!emailController.text.contains('@')) {
      showError('Format email tidak valid!');
      return false;
    }
    if (passwordController.text.length < 6) {
      showError('Password minimal harus 6 karakter!');
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

  // --- LOGIN BIASA ---
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
      showError('Gagal terhubung ke server. Periksa koneksi Backend.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // --- GOOGLE SIGN IN ---
  Future<void> handleGoogleSignIn() async {
    try {
      setState(() => isLoading = true);

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        if (mounted) setState(() => isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // WEB TRICK: Di Web, terkadang idToken ada di googleAuth.idToken 
      // atau kita bisa gunakan accessToken jika backend kamu mendukungnya.
      final String? tokenToSend = googleAuth.idToken ?? googleAuth.accessToken;

      if (tokenToSend == null) {
        showError("Gagal mendapatkan token dari Google.");
        return;
      }

      // Kirim ke Backend
      final result = await AuthService.googleLogin(
        idToken: tokenToSend, 
      );

      if (result['success']) {
        _onLoginSuccess(result['data']);
      } else {
        showError(result['message']);
      }
    } catch (error) {
      showError("Login Gagal: $error");
      print("Detail Error: $error");
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selamat Datang, ${data['user']['name']}!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trailblazer Login'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Agar column tidak memakan ruang berlebih
            children: [
              const Icon(Icons.auto_awesome_outlined, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 10),
              const Text(
                'Honkai Star Retail',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              
              // Tombol Login Biasa
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : handleLogin,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('LOGIN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 15),
              const Text("OR", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 15),

              // Tombol Google Sign In yang sudah dibenahi agar tidak Overflow
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: isLoading ? null : handleGoogleSignIn,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.network(
                        'https://www.gstatic.com/images/branding/product/2x/googleg_48dp.png',
                        height: 24,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.login, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Flexible(
                        child: Text(
                          'Masuk dengan Google',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterPage()),
                  );
                },
                child: const Text('Belum punya akun? Daftar di sini'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}