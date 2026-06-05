import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/cart_service.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final TextEditingController _qtyController = TextEditingController(text: "1");
  bool isAdding = false;

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> handleAddToCart(ProductModel product, String token) async {
    if (product.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Product ID not found")),
      );
      return;
    }

    int inputQty = int.tryParse(_qtyController.text) ?? 1;

    setState(() => isAdding = true);

    try {
      final cartItems = await CartService.getCartItems(token);
      
      int qtyExistingInCart = 0;
      for (var item in cartItems) {
        if (item['product_id'] == product.id) {
          qtyExistingInCart = item['quantity'];
          break;
        }
      }

      if ((qtyExistingInCart + inputQty) > product.stock) {
        setState(() => isAdding = false);
        int sisaBolehTambah = product.stock - qtyExistingInCart;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              qtyExistingInCart > 0 
                ? "Failed! Already have $qtyExistingInCart in cart. Can only add $sisaBolehTambah more."
                : "Insufficient stock!",
            ),
            backgroundColor: Colors.orange.shade900,
          ),
        );
        return; 
      }

      final result = await CartService.addToCart(
        token: token,
        productId: product.id!,
        quantity: inputQty,
      );

      if (mounted) {
        setState(() => isAdding = false);
        
        bool isSuccess = result['success'] == true || 
                         result['message'].toString().toLowerCase().contains('Success');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? "Successfully added to cart."),
            backgroundColor: isSuccess ? Colors.green : Colors.red,
            duration: const Duration(seconds: 1),
          ),
        );

        if (isSuccess) {
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted) Navigator.pop(context);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isAdding = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error!: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)!.settings.arguments as ProductModel;
    final token = Provider.of<AuthProvider>(context).token;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              product.imageUrl,
              width: double.infinity,
              height: 350,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              headers: const {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
                'Referer': 'https://honkai-star-rail.fandom.com/',
              },
              errorBuilder: (context, e, s) => const SizedBox(
                height: 350,
                child: Center(child: Icon(Icons.broken_image, size: 100, color: Colors.white24)),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 5),
                  Text(product.type, style: const TextStyle(color: Colors.blueAccent, fontSize: 16)),
                  const SizedBox(height: 20),
                  Text('${product.price.toStringAsFixed(0)} Credits', 
                    style: const TextStyle(fontSize: 24, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                  
                  const Divider(height: 40, color: Colors.white24),
                  
                  const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 10),
                  Text(
                    product.description ?? 'There are not descriptions for this item.', 
                    style: const TextStyle(fontSize: 15, color: Colors.white70, height: 1.5)
                  ),
                  
                  const SizedBox(height: 30),
                  
                  Row(
                    children: [
                      const Text('Stock:', style: TextStyle(fontSize: 16, color: Colors.white70)),
                      const SizedBox(width: 8),
                      Text('${product.stock}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                      const Spacer(),
                      
                      IconButton(
                        onPressed: () {
                          int current = int.tryParse(_qtyController.text) ?? 1;
                          if (current > 1) {
                            setState(() => _qtyController.text = (current - 1).toString());
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
                      ),
                      
                      SizedBox(
                        width: 70,
                        child: TextField(
                          controller: _qtyController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                          decoration: const InputDecoration(
                            isDense: true,
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue, width: 2)),
                          ),
                          onChanged: (value) {
                            int? val = int.tryParse(value);
                            if (val != null) {
                              if (val > product.stock) {
                                _qtyController.text = product.stock.toString();
                                _qtyController.selection = TextSelection.fromPosition(
                                  TextPosition(offset: _qtyController.text.length)
                                );
                              } else if (val < 1) {
                                _qtyController.text = "1";
                              }
                            }
                          },
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          int current = int.tryParse(_qtyController.text) ?? 1;
                          if (current < product.stock) {
                            setState(() => _qtyController.text = (current + 1).toString());
                          }
                        },
                        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: (isAdding || product.stock <= 0) 
              ? null 
              : () => handleAddToCart(product, token!),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 55),
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade800,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
          ),
          child: isAdding 
              ? const SizedBox(height: 25, width: 25, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
              : Text(
                  product.stock > 0 ? 'ADD TO CART' : 'STOCK EMPTY',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}