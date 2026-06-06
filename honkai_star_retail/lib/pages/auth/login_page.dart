import 'dart:ui' show ImageFilter; // WAJIB DIIMPORT UNTUK EFEK BLUR
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
    clientId: '821549327398-r34pvjg4hv7ufqug99lo5u85gns4jgit.apps.googleusercontent.com',
    scopes: ['email', 'profile', 'openid'],
  );
  
  bool isLoading = false;
  bool _obscurePassword = true;

  bool validateInput() {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showError('Email and Password must not be empty!');
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
      showError('Failed to connect to server');
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
        showError("Failed to get token.");
        return;
      }

      final result = await AuthService.googleLogin(idToken: tokenToSend);

      if (result['success']) {
        _onLoginSuccess(result['data']);
      } else {
        showError(result['message']);
      }
    } catch (error) {
      showError("Login failed: $error");
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
      backgroundColor: const Color(0xFF0C0C0D),
      // Membuat background naik menembus status bar atas HP
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // --- LAYER 1: GAMBAR BACKGROUND DARI URL ---
          Positioned.fill(
            child: Image.network(
              'https://upload-os-bbs.hoyolab.com/upload/2023/01/28/17138284/85778450a3fbe5b61c4c0c2b47b82dc2_2925831787640733185.png', // Ganti dengan URL background HSR pilihanmu
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),

          // --- LAYER 2: EFEK BLUR + LAPISAN GELAP ---
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0), // Intensitas blur
              child: Container(
                color: Colors.black.withOpacity(0.2), // Gelap transparan agar teks kontras
              ),
            ),
          ),

          // --- LAYER 3: KONTEN UTAMA FORM ---
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                        fillColor: const Color(0xFF1A1A1A).withOpacity(0.85), // Dibuat sedikit transparan
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
                        fillColor: const Color(0xFF1A1A1A).withOpacity(0.85), // Dibuat sedikit transparan
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
                    
                    // Tombol Login
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

                    // Tombol Google
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: OutlinedButton.icon(
                        onPressed: isLoading ? null : handleGoogleSignIn,
                        icon: Image.asset(
                          'assets/images/google_logo.png',
                          height: 24,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.login, color: Colors.white),
                        ),
                        label: const Text(
                          'Login with Google',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.3), // Penahan transparan agar tombol Google kontras
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
                        'No account yet? Register here',
                        style: TextStyle(color: Colors.blueAccent),
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