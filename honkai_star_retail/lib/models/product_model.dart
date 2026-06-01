class ProductModel {
  final int? id; // Pakai ? agar aman jika ID belum ter-load
  final String name;
  final String type;
  final String? description; // Deskripsi sering kali boleh null
  final int stock;
  final String imageUrl;
  final double price;

  ProductModel({
    this.id,
    required this.name,
    required this.type,
    this.description,
    required this.stock,
    required this.imageUrl,
    required this.price,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      // Casting ID ke int (antisipasi jika DB kirim string)
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()),
      
      name: json['name']?.toString() ?? 'Tanpa Nama',
      type: json['type']?.toString() ?? 'General',
      description: json['description']?.toString() ?? '',
      
      // Ambil stock dengan proteksi default 0
      stock: int.tryParse(json['stock'].toString()) ?? 0,
      
      // Map 'image_url' dari JSON ke properti 'imageUrl'
      imageUrl: json['image_url']?.toString() ?? '',
      
      // Proteksi harga agar tidak error saat parsing
      price: double.tryParse(json['price'].toString()) ?? 0.0,
    );
  }

  // Bonus: Fungsi untuk mengubah Objek kembali ke JSON (berguna untuk POST/PUT)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'stock': stock,
      'image_url': imageUrl,
      'price': price,
    };
  }
}