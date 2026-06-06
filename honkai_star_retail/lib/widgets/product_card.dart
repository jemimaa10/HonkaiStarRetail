import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../utils/constants.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Menggunakan Container solid (bukan Card bawaan) agar benar-benar memblokir background blur di belakangnya
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111112), // KUNCI UTAMA: Hitam pekat solid, tidak transparan sama sekali
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.08), // Border tipis aesthetic khas game
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.2,
              child: Container(
                color: const Color(0xFF1A1A1C), // Background default jika gambar loading
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  filterQuality: FilterQuality.high,
                  headers: const {
                    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
                    'Referer': 'https://honkai-star-rail.fandom.com/',
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.white10,
                    child: const Icon(Icons.broken_image, size: 25, color: Colors.white24),
                  ),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 13, 
                        color: Colors.white, // Teks dipastikan putih murni
                      ),
                    ),
                    Text(
                      product.type, 
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white60, fontSize: 10),
                    ),
                    const SizedBox(height: 2), 
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '${product.price.toStringAsFixed(0)} Credits', 
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.blueAccent, 
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Text(
                          'Stock: ${product.stock}',
                          style: const TextStyle(fontSize: 10, color: Colors.white38),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}