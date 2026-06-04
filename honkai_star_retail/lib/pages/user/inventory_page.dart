import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/inventory_service.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => InventoryPageState();
}

class InventoryPageState extends State<InventoryPage> {
  List<dynamic> inventoryItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchInventory();
  }

  Future<void> fetchInventory() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    final token = Provider.of<AuthProvider>(context, listen: false).token;
    
    try {
      final data = await InventoryService.getInventory(token!);
      if (mounted) {
        setState(() {
          inventoryItems = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil inventory: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: fetchInventory,
      child: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : inventoryItems.isEmpty 
          ? ListView(
              children: const [
                SizedBox(height: 200),
                Center(child: Text("Inventory kamu masih kosong.")),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: inventoryItems.length,
              itemBuilder: (context, index) {
                final item = inventoryItems[index];
                
                // 1. Logika Nama Produk
                final String displayName = item['name'] ?? 
                                           item['product_name'] ?? 
                                           item['product']?['name'] ?? 
                                           'Item';

                // 2. Logika URL Gambar (Cek berbagai kemungkinan key dari API)
                final String? imageUrl = item['image_url'] ?? 
                                         item['imageUrl'] ?? 
                                         item['product']?['image_url'];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    // --- PERBAIKAN: MENGGUNAKAN GAMBAR ASLI ITEM ---
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              width: 55,
                              height: 55,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 55, height: 55, color: Colors.grey[800],
                                child: const Icon(Icons.broken_image, color: Colors.white54),
                              ),
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: 55, height: 55, color: Colors.grey[900],
                                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                );
                              },
                            )
                          : Container(
                              width: 55, height: 55, color: Colors.blueGrey[900],
                              child: const Icon(Icons.inventory_2, color: Colors.white54),
                            ),
                    ),
                    title: Text(
                      displayName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top :4.0),
                      child: Text(
                        'Kuantitas: ${item['quantity']}',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                  ),
                );
              },
            ),
    );
  }
}