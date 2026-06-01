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

  // Daftar tipe produk awal
  final List<String> productTypes = [
    'Gland Packing', 
    'Gasket', 
    'Graphite Ring', 
    'Light Cone', // Tambahkan ini agar sinkron dengan data kamu
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

    // --- LOGIKA PENGAMAN DROPDOWN (PENTING!) ---
    if (widget.product != null) {
      String? typeFromDb = widget.product!.type;
      
      // Jika tipe dari DB tidak ada di list, kita tambahkan otomatis ke list
      // supaya Dropdown tidak crash (Layar Merah)
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
      appBar: AppBar(
        title: Text(widget.product == null ? 'Tambah Produk' : 'Edit Produk'),
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nama Produk', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 15),
                  
                  // Dropdown dengan item yang sudah dipastikan mengandung value dari DB
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(labelText: 'Tipe Produk', border: OutlineInputBorder()),
                    items: productTypes.map((t) {
                      return DropdownMenuItem(value: t, child: Text(t));
                    }).toList(),
                    onChanged: (val) => setState(() => selectedType = val),
                    validator: (v) => v == null ? 'Pilih tipe produk' : null,
                  ),
                  
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: priceController,
                          decoration: const InputDecoration(labelText: 'Harga', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Isi harga' : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: stockController,
                          decoration: const InputDecoration(labelText: 'Stok', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Isi stok' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: imageUrlController,
                    decoration: const InputDecoration(labelText: 'URL Gambar', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'URL gambar wajib' : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Deskripsi (Opsional)', border: OutlineInputBorder()),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                      ),
                      child: const Text('SIMPAN PRODUK', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}