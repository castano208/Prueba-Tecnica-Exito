import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../data/models/product.dart';
import '../providers/product_provider.dart';

/// Widget de entrada personalizada para cantidades con botones sincronizados
/// Vista avanzada con campo de entrada editable y botones de control
class CustomQuantityInput extends StatefulWidget {
  final Product product;
  final bool isExpressMode;

  const CustomQuantityInput({
    super.key,
    required this.product,
    required this.isExpressMode,
  });

  @override
  State<CustomQuantityInput> createState() => _CustomQuantityInputState();
}

class _CustomQuantityInputState extends State<CustomQuantityInput> {
  late TextEditingController controller;
  bool _updatingFromButton = false;

  @override
  void initState() {
    super.initState();
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final initialQuantity = productProvider.getProductQuantity(widget.product);
    controller = TextEditingController(
      text: initialQuantity > 0 ? initialQuantity.toString() : "1",
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// Actualiza la cantidad desde los botones y sincroniza el input
  void _updateQuantityFromButton(int newQuantity) {
    _updatingFromButton = true;
    controller.text = newQuantity.toString();
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
    setState(() {});
    _updatingFromButton = false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final fillColor = widget.isExpressMode
            ? const Color.fromARGB(255, 174, 204, 255)
            : const Color.fromARGB(255, 255, 223, 175);

        final currentQuantity = productProvider.getProductQuantity(widget.product);

        return currentQuantity == 0
            ? SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    productProvider.addToCart(widget.product, 1);
                    _updateQuantityFromButton(1);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.isExpressMode 
                        ? Colors.blueAccent 
                        : Colors.orange,
                  ),
                  child: const Text("Agregar"),
                ),
              )
            : Column(
                children: [
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelText: "Cantidad",
                      fillColor: fillColor,
                      filled: true,
                      labelStyle: const TextStyle(color: Colors.black),
                    ),
                    style: const TextStyle(color: Colors.black),
                    onChanged: (value) {
                      if (_updatingFromButton) return;
                      final int inputValue = int.tryParse(value) ?? 0;
                      if (inputValue < 0) return;

                      final int currentQuantity = productProvider.getProductQuantity(widget.product);
                      final int difference = inputValue - currentQuantity;
                      if (difference != 0) {
                        productProvider.addToCart(widget.product, difference);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          productProvider.removeFromCart(widget.product);
                          final newQuantity = productProvider.getProductQuantity(widget.product);
                          _updateQuantityFromButton(newQuantity);
                        },
                      ),
                      Text(
                        productProvider.getProductQuantity(widget.product) > 999999
                            ? "999999+"
                            : productProvider.getProductQuantity(widget.product).toString(),
                        style: const TextStyle(fontSize: 14),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          productProvider.addToCart(widget.product, 1);
                          final newQuantity = productProvider.getProductQuantity(widget.product);
                          _updateQuantityFromButton(newQuantity);
                        },
                      ),
                    ],
                  ),
                ],
              );
      },
    );
  }
}
