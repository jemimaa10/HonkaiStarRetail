import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfilePage extends StatelessWidget {
  // Pastikan constructor-nya 'const' dan tidak meminta parameter wajib
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Kita ambil data user dari Provider saja, jangan dari constructor
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 20),
          Text(user?['name'] ?? 'User', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(user?['email'] ?? '', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              authProvider.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}