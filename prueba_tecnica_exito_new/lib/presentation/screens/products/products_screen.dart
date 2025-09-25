import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/product.dart';
import '../../providers/express_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/search_provider.dart';
import '../../widgets/simple_quantity_buttons.dart';

/// Pantalla de productos que muestra productos por categoría
/// Vista normal con botones simples para gestionar cantidades
class ProductsScreen extends StatefulWidget {
  final String category;
  
  const ProductsScreen({super.key, required this.category});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late Future<List<Product>> _productsFuture;
  final Map<int, TextEditingController> _controllers = {};
  @override
  void initState() {
    super.initState();
    _productsFuture = _loadProducts();
    // El sistema de tiempo optimizado se maneja automáticamente
  }

  @override
  void dispose() {
    _controllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  /// Carga los productos de la categoría y precarga las imágenes
  Future<List<Product>> _loadProducts() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    
    // Cargar todos los productos para búsqueda
    await searchProvider.loadAllProducts();
    
    final products = await productProvider.getProductsByCategory(widget.category);
    
    // Precargar imágenes para mejor rendimiento
    for (final product in products) {
      if (!mounted) break;
      await precacheImage(NetworkImage(product.image), context);
    }
    
    return products;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<ExpressProvider, ProductProvider, SearchProvider>(
      builder: (context, expressProvider, productProvider, searchProvider, child) {
        final isExpressMode = expressProvider.isExpressModeActive;
        final colorPrice = isExpressMode 
            ? Colors.blue.shade600 
            : const Color.fromARGB(255, 255, 10, 10);
        final colorButton = isExpressMode ? Colors.blue : Colors.orange;
        final columns = (MediaQuery.of(context).size.width ~/ 180).clamp(2, 4);

        return Scaffold(
          appBar: AppBar(
            title: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: "¿Qué buscas?",
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.black,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
                onChanged: (value) {
                  searchProvider.setSearchQuery(value);
                },
              ),
            ),
            backgroundColor: const Color.fromARGB(255, 255, 234, 0),
            actions: [
              // Cart button with badge
              Padding(
                padding: const EdgeInsets.only(right: 11),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart, color: Colors.black),
                      onPressed: () => context.push('/cart'),
                    ),
                    if (productProvider.totalItems > 0)
                      Positioned(
                        left: 25,
                        bottom: 26,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: colorButton,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            productProvider.totalItems < 99 
                                ? productProvider.totalItems.toString() 
                                : "99+",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Barra de información de dirección
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.black,
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color.fromARGB(255, 255, 234, 0),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Santiago Henao recíbelo en prado Cl. 64 #49-21",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.edit,
                      color: Color.fromARGB(255, 255, 234, 0),
                      size: 18,
                    ),
                  ],
                ),
              ),
              // Título de la categoría
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.grey[100],
                child: Text(
                  widget.category.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              // Lista de productos
              Expanded(
                child: FutureBuilder<List<Product>>(
                  future: _productsFuture,
                  builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              final allProducts = snapshot.data ?? [];
              
              if (allProducts.isEmpty) {
                return const Center(child: Text("No products available"));
              }

              // Filtrar productos si hay búsqueda
              List<Product> products = allProducts;
              if (searchProvider.searchQuery.isNotEmpty) {
                final query = searchProvider.searchQuery.toLowerCase();
                products = allProducts.where((product) {
                  return product.title.toLowerCase().contains(query) ||
                         product.description.toLowerCase().contains(query);
                }).toList();
              }

              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.65,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Image.network(
                            product.image,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "\$${product.price.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: colorPrice,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text("${product.rate} (${product.count})"),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SimpleQuantityButtons(
                                product: product,
                                isExpressMode: isExpressMode,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
