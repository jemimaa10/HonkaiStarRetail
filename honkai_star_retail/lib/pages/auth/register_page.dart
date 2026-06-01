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

  // Validasi Input (Syarat: Minimal 3 jenis validasi)
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

    final result = await AuthService.register(
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text,
    );

    setState(() => isLoading = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registrasi Berhasil! Silakan Login."), backgroundColor: Colors.green),
      );
      Navigator.pop(context); // Kembali ke halaman login
    } else {
      showError(result['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trailblazer Registration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.person_add_alt_1, size: 80, color: Colors.blueAccent),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : handleRegister,
                child: isLoading ? const CircularProgressIndicator() : const Text('REGISTER'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}