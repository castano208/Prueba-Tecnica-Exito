import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/product.dart';
import '../providers/product_provider.dart';

/// Widget de botones simples para gestionar cantidades
/// Vista normal sin campo de entrada, solo botones de incremento/decremento
class SimpleQuantityButtons extends StatelessWidget {
  final Product product;
  final bool isExpressMode;

  const SimpleQuantityButtons({
    super.key,
    required this.product,
    required this.isExpressMode,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final currentQuantity = productProvider.getProductQuantity(product);
        final colorButton = isExpressMode ? Colors.blue : Colors.orange;

        return currentQuantity == 0
            ? SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    productProvider.addToCart(product, 1);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorButton,
                  ),
                  child: const Text("Agregar"),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      productProvider.removeFromCart(product);
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: colorButton.withOpacity(0.2),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorButton.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      currentQuantity > 99
                          ? "99+und"
                          : currentQuantity.toString() + "und",
                      style: TextStyle(
                        fontSize:  currentQuantity > 99 ? 10 : 13,
                        fontWeight: FontWeight.bold,
                        color: colorButton,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      productProvider.addToCart(product, 1);
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: colorButton.withOpacity(0.2),
                    ),
                  ),
                ],
              );
      },
    );
  }
}
