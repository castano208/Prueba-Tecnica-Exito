import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../data/models/product.dart';
import '../../providers/express_provider.dart';
import '../../providers/product_provider.dart';

/// Pantalla del carrito que muestra los productos agregados
/// Permite gestionar cantidades y ver el total de la compra
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final Map<Product, TextEditingController> _controllers = {};
  @override
  void initState() {
    super.initState();
    // El sistema de tiempo optimizado se maneja automáticamente
  }

  @override
  void dispose() {
    _controllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ExpressProvider, ProductProvider>(
      builder: (context, expressProvider, productProvider, child) {
        final isExpressMode = expressProvider.isExpressModeActive;
        final themeColor = isExpressMode ? Colors.blue : Colors.orange;

        // Initialize controllers for products in cart
        productProvider.cartItems.forEach((product, quantity) {
          _controllers.putIfAbsent(
            product,
            () => TextEditingController(text: quantity.toString()),
          );
        });

        return Scaffold(
          appBar: AppBar(
            title: const Text("Shopping Cart"),
            backgroundColor: themeColor,
          ),
          body: productProvider.cartItems.isEmpty
              ? const Center(child: Text("Cart is empty"))
              : Column(
                  children: [
                    // Product list
                    Expanded(
                      child: ListView(
                        children: productProvider.cartItems.entries.map((entry) {
                          final product = entry.key;
                          final controller = _controllers[product]!;
                          bool _updatingFromButton = false;

                          return ListTile(
                            leading: Image.network(product.image, width: 50),
                            title: Text(product.title),
                            subtitle: Text(
                              "\$${product.price.toStringAsFixed(2)}",
                              style: TextStyle(color: themeColor),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Remove button
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    productProvider.removeFromCart(product);
                                    final newQuantity = productProvider.getProductQuantity(product);
                                    _updatingFromButton = true;
                                    controller.text = newQuantity.toString();
                                    controller.selection = TextSelection.fromPosition(
                                      TextPosition(offset: controller.text.length),
                                    );
                                    _updatingFromButton = false;
                                    setState(() {});
                                  },
                                ),
                                // Editable input
                                SizedBox(
                                  width: 50,
                                  child: TextField(
                                    controller: controller,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    onChanged: (value) {
                                      if (_updatingFromButton) return;
                                      int inputValue = int.tryParse(value) ?? 0;
                                      if (inputValue < 0) return;

                                      final currentQuantity = productProvider.getProductQuantity(product);
                                      final difference = inputValue - currentQuantity;
                                      if (difference != 0) {
                                        productProvider.addToCart(product, difference);
                                        setState(() {});
                                      }
                                    },
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                                    ),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                // Add button
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    productProvider.addToCart(product, 1);
                                    final newQuantity = productProvider.getProductQuantity(product);
                                    _updatingFromButton = true;
                                    controller.text = newQuantity.toString();
                                    controller.selection = TextSelection.fromPosition(
                                      TextPosition(offset: controller.text.length),
                                    );
                                    _updatingFromButton = false;
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    // Total bar
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: themeColor.withOpacity(0.1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            "\$${productProvider.totalPrice.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
