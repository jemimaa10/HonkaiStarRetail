import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../utils/constants.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap, // Menuju Product Detail Page [cite: 39]
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  product.imageUrl, // Link URL saja 
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(product.type, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 5),
                  Text('${product.price} Credits', style: const TextStyle(color: AppConstants.primaryColor, fontWeight: FontWeight.bold)),
                  Text('Stock: ${product.stock}', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}