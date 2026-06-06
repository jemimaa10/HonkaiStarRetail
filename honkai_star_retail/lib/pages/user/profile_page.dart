import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blueAccent, width: 2),
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFF1A1A1A),
              backgroundImage: user?['avatar_url'] != null 
                  ? NetworkImage(user!['avatar_url']) 
                  : null,
              child: user?['avatar_url'] == null 
                  ? const Icon(Icons.person, size: 60, color: Colors.white54) 
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          
          Text(
            user?['name'] ?? 'User', 
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          
          // Email User
          Text(
            user?['email'] ?? '', 
            style: const TextStyle(color: Colors.white54, fontSize: 16),
          ),
          const SizedBox(height: 40),
          
          SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                authProvider.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
              icon: const Icon(Icons.logout),
              label: const Text('LOGOUT USER', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent, 
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          )
        ],
      ),
    );
  }
}