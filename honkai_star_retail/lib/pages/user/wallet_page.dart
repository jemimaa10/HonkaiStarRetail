import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/wallet_service.dart';
import '../../utils/constants.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  bool isTopUpLoading = false;

  void handleTopUp(String token) async {
    setState(() => isTopUpLoading = true);
    final result = await WalletService.topUp(token);
    setState(() => isTopUpLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'])),
    );
    setState(() {}); // Refresh UI untuk ambil saldo baru
  }

  @override
  Widget build(BuildContext context) {
    final token = Provider.of<AuthProvider>(context).token;

    return Scaffold(
      appBar: AppBar(title: const Text('My Wallet')),
      body: FutureBuilder<double>(
        future: WalletService.getBalance(token!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          final balance = snapshot.data ?? 0.0;
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(colors: [Colors.indigo, AppConstants.primaryColor]),
                  ),
                  child: Column(
                    children: [
                      const Text('Current Balance', style: TextStyle(color: Colors.white70)),
                      Text('${balance.toStringAsFixed(0)} Credits', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Tombol Top Up Gratis (Sesuai skenario project)
                ElevatedButton.icon(
                  onPressed: isTopUpLoading ? null : () => handleTopUp(token),
                  icon: const Icon(Icons.add_circle),
                  label: Text(isTopUpLoading ? 'Processing...' : 'CLAIM 50.000 CREDITS'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 50)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}