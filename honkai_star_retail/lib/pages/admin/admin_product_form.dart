import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/product_service.dart';
import '../../models/product_model.dart';

class AdminProductForm extends StatefulWidget {
  final ProductModel? product; 

  const AdminProductForm({super.key, this.product});

  @override
  State<AdminProductForm> createState() => _AdminProductFormState();
}

class _AdminProductFormState extends State<AdminProductForm> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController nameController;
  late TextEditingController descController;
  late TextEditingController priceController;
  late TextEditingController stockController;
  late TextEditingController imageUrlController;
  
  String? selectedType;
  bool isLoading = false;

  final List<String> productTypes = [ 
    'Light Cone',
    'Relic',
    'Material',
    'Currency',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    
    nameController = TextEditingController(text: widget.product?.name ?? '');
    descController = TextEditingController(text: widget.product?.description ?? '');
    priceController = TextEditingController(text: widget.product?.price?.toString() ?? '');
    stockController = TextEditingController(text: widget.product?.stock?.toString() ?? '');
    imageUrlController = TextEditingController(text: widget.product?.imageUrl ?? '');

    if (widget.product != null) {
      String? typeFromDb = widget.product!.type;
      if (typeFromDb != null && typeFromDb.isNotEmpty) {
        if (!productTypes.contains(typeFromDb)) {
          productTypes.add(typeFromDb);
        }
        selectedType = typeFromDb;
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    priceController.dispose();
    stockController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    final productData = {
      'name': nameController.text,
      'type': selectedType,
      'description': descController.text,
      'price': double.tryParse(priceController.text) ?? 0.0,
      'stock': int.tryParse(stockController.text) ?? 0,
      'image_url': imageUrlController.text,
    };

    try {
      bool success;
      if (widget.product == null) {
        success = await ProductService.addProduct(token!, productData);
      } else {
        success = await ProductService.updateProduct(token!, widget.product!.id!, productData);
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil menyimpan produk!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0C0D), // Background gelap senada
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C0C0D),
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 80, // Tinggi yang sama dengan MainNavigation
        iconTheme: const IconThemeData(color: Colors.white), // Warna tombol back
        // MENGGANTI TEKS DENGAN LOGO
        title: Image.asset(
          'assets/images/logo_retail.png',
          height: 90, 
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Text(
            "ADMIN PANEL",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product == null ? "Tambah Produk Baru" : "Edit Detail Produk",
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  
                  _buildTextField(nameController, 'Nama Produk', Icons.shopping_bag_outlined),
                  const SizedBox(height: 15),
                  
                  DropdownButtonFormField<String>(
                    dropdownColor: const Color(0xFF1A1A1A),
                    value: selectedType,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Tipe Produk', Icons.category_outlined),
                    items: productTypes.map((t) {
                      return DropdownMenuItem(value: t, child: Text(t));
                    }).toList(),
                    onChanged: (val) => setState(() => selectedType = val),
                    validator: (v) => v == null ? 'Pilih tipe produk' : null,
                  ),
                  
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(priceController, 'Harga', Icons.payments_outlined, isNumber: true)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildTextField(stockController, 'Stok', Icons.inventory_2_outlined, isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(imageUrlController, 'URL Gambar', Icons.image_outlined),
                  const SizedBox(height: 15),
                  _buildTextField(descController, 'Deskripsi (Opsional)', Icons.description_outlined, maxLines: 3),
                  
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                      ),
                      child: const Text('SIMPAN PERUBAHAN', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // Helper untuk merapikan desain TextField agar senada dengan Login
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: _inputDecoration(label, icon),
      validator: (v) => v!.isEmpty && label != 'Deskripsi (Opsional)' ? 'Wajib diisi' : null,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.blueAccent),
      filled: true,
      fillColor: const Color(0xFF1A1A1A),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white12)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.blueAccent)),
    );
  }
}