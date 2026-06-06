import 'dart:ui' show ImageFilter; // WAJIB DIIMPORT UNTUK EFEK BLUR BACKGROUND
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
          const SnackBar(content: Text('Successfully saved product!'), backgroundColor: Colors.green),
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
      backgroundColor: const Color(0xFF0C0C0D),
      extendBodyBehindAppBar: true, // 1. Membuat background naik penuh melewati AppBar atas
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 2. Diubah ke transparan agar background menyatu
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 80, 
        iconTheme: const IconThemeData(color: Colors.white), 
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
      // 3. MENGGUNAKAN STACK GLOBAL PADA BODY SEPERTI PAGE SEBELUMNYA
      body: Stack(
        children: [
          // LAYER 1: Gambar Latar Belakang .png Pilihanmu dari Hoyolab
          Positioned.fill(
            child: Image.network(
              'https://upload-os-bbs.hoyolab.com/upload/2023/01/28/17138284/85778450a3fbe5b61c4c0c2b47b82dc2_2925831787640733185.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),

          // LAYER 2: Efek Keburaman (Blur) + Lapisan Transparan Gelap
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
              child: Container(
                color: Colors.black.withOpacity(0.6), // Sedikit lebih gelap agar field input tetap terlihat jelas
              ),
            ),
          ),

          // LAYER 3: Konten Utama Form (Menggunakan SafeArea agar tidak terpotong notch)
          SafeArea(
            child: isLoading 
              ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product == null ? "Add New Product" : "Edit Product Details",
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        
                        _buildTextField(nameController, 'Product Name', Icons.shopping_bag_outlined),
                        const SizedBox(height: 15),
                        
                        DropdownButtonFormField<String>(
                          dropdownColor: const Color(0xFF1A1A1A),
                          value: selectedType,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('Product Type', Icons.category_outlined),
                          items: productTypes.map((t) {
                            return DropdownMenuItem(value: t, child: Text(t));
                          }).toList(),
                          onChanged: (val) => setState(() => selectedType = val),
                          validator: (v) => v == null ? 'Choose product type' : null,
                        ),
                        
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(child: _buildTextField(priceController, 'Price', Icons.payments_outlined, isNumber: true)),
                            const SizedBox(width: 10),
                            Expanded(child: _buildTextField(stockController, 'Stock', Icons.inventory_2_outlined, isNumber: true)),
                          ],
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(imageUrlController, 'Image URL', Icons.image_outlined),
                        const SizedBox(height: 15),
                        _buildTextField(descController, 'Description (Optional)', Icons.description_outlined, maxLines: 3),
                        
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
                            child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: _inputDecoration(label, icon),
      validator: (v) => v!.isEmpty && label != 'Description (Optional)' ? 'Must be filled' : null,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.blueAccent),
      filled: true,
      // PERBAIKAN: Ditambahkan .withOpacity(0.6) agar kotak input menjadi semi-transparan yang mewah
      fillColor: const Color(0xFF1A1A1A).withOpacity(0.6),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white12)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.blueAccent)),
    );
  }
}