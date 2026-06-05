import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/wallet_service.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => WalletPageState();
}

class WalletPageState extends State<WalletPage> {
  double balance = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWallet();
  }

  Future<void> fetchWallet() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    final token = Provider.of<AuthProvider>(context, listen: false).token;

    try {
      final double data = await WalletService.getBalance(token!);
      if (mounted) {
        setState(() {
          balance = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get credits: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleTopUp() async {
    setState(() => isLoading = true);
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    try {
      final result = await WalletService.topUp(token!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Successfully added 50.000 Credits!'),
            backgroundColor: Colors.green,
          ),
        );
        fetchWallet();
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to top up!: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    return RefreshIndicator(
      onRefresh: fetchWallet,
      color: Colors.blueAccent,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF3F51B5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Credits', style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 8),
                isLoading 
                  ? const SizedBox(height: 38, width: 38, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('${balance.toStringAsFixed(0)} Credits', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const SizedBox(height: 20),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Honkai Star Retail Card', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    Icon(Icons.account_balance_wallet, color: Colors.white54, size: 20),
                  ],
                )
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _handleTopUp,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('TOP UP +50.000 CREDITS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 2,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 30),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text("Transaction History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),

          const SizedBox(height: 10),

          FutureBuilder<List<dynamic>>(
            key: ValueKey(balance), 
            future: WalletService.getTransactions(token!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(30.0),
                  child: CircularProgressIndicator(),
                ));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(50.0),
                    child: Column(
                      children: [
                        Icon(Icons.history, size: 50, color: Colors.white24),
                        SizedBox(height: 10),
                        Text("No transactions yet", style: TextStyle(color: Colors.white24)),
                      ],
                    ),
                  ),
                );
              }

              final transactions = snapshot.data!;

              return ListView.builder(
                shrinkWrap: true, 
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  final bool isTopup = tx['type'] == 'topup';
                  final double amount = double.tryParse(tx['amount'].toString()) ?? 0;

                  String displayTitle = isTopup ? "Top Up Credits" : (tx['description'] ?? "Item Purchase");

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    color: Colors.white.withOpacity(0.05),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isTopup ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isTopup ? Icons.add_rounded : Icons.shopping_cart_checkout_rounded,
                          color: isTopup ? Colors.greenAccent : Colors.redAccent,
                          size: 24,
                        ),
                      ),
                      title: Text(
                        displayTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                      ),
                      subtitle: Text(
                        tx['created_at'].toString().split('T')[0],
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                      ),
                      trailing: Text(
                        "${isTopup ? '+' : ''}${amount.toStringAsFixed(0)}",
                        style: TextStyle(
                          color: isTopup ? Colors.greenAccent : Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 100), 
        ],
      ),
    );
  }
}