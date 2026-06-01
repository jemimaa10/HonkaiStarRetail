import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/inventory_service.dart';
import '../../utils/constants.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final token = Provider.of<AuthProvider>(context).token;

    return Scaffold(
      appBar: AppBar(title: const Text('My Inventory')),
      body: FutureBuilder<List<dynamic>>(
        future: InventoryService.getInventory(token!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Inventory masih kosong. Ayo belanja!'));
          }

          final items = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(15),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                color: AppConstants.cardColor,
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(item['image_url'], width: 50, height: 50, fit: BoxFit.cover),
                  ),
                  title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Type: ${item['type']}'),
                  trailing: CircleAvatar(
                    backgroundColor: AppConstants.primaryColor,
                    child: Text('${item['quantity']}', style: const TextStyle(color: Colors.white)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}