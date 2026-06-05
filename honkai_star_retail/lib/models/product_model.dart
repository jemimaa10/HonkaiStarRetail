class ProductModel {
  final int? id;
  final String name;
  final String type;
  final String? description;
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
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()),
      
      name: json['name']?.toString() ?? 'No name',
      type: json['type']?.toString() ?? 'General',
      description: json['description']?.toString() ?? '',
      
      stock: int.tryParse(json['stock'].toString()) ?? 0,
      
      imageUrl: json['image_url']?.toString() ?? '',
      
      price: double.tryParse(json['price'].toString()) ?? 0.0,
    );
  }

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