import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../presentation/providers/express_provider.dart';
import '../../../presentation/providers/product_provider.dart';
import '../../../presentation/providers/search_provider.dart';
import '../../../presentation/widgets/express_mode_switch.dart';

/// Pantalla principal que muestra las categorías de productos
/// Permite navegar a las diferentes categorías y gestionar el modo express
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  late Timer _timer;
  late Future<List<String>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _loadCategories();
    _startTimeVerification();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  /// Inicia la verificación periódica del horario express
  void _startTimeVerification() {
    final expressProvider = Provider.of<ExpressProvider>(context, listen: false);
    
    // Verificar inmediatamente
    expressProvider.checkExpressTime();

    // Verificar cada minuto
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      await expressProvider.checkExpressTime();
    });
  }

  /// Carga las categorías de productos desde el provider
  Future<List<String>> _loadCategories() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    return await productProvider.getCategories();
  }

  /// Construye la vista de categorías
  Widget _buildCategoriesGrid() {
    return FutureBuilder<List<String>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No categories available'));
        }

        final categories = snapshot.data!;
        final crossAxisCount = (MediaQuery.of(context).size.width ~/ 180).clamp(2, 4);

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            return GestureDetector(
              onTap: () {
                final expressProvider = Provider.of<ExpressProvider>(context, listen: false);
                if (expressProvider.customViewActive) {
                  context.push('/products-custom/$category');
                } else {
                  context.push('/products/$category');
                }
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.category,
                      size: 48,
                      color: Colors.blueAccent,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      category.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Construye los resultados de búsqueda
  Widget _buildSearchResults(SearchProvider searchProvider) {
    return FutureBuilder<List<String>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No categories available'));
        }

        final allCategories = snapshot.data!;
        final query = searchProvider.searchQuery.toLowerCase();
        
        // Filtrar categorías que coincidan con la búsqueda
        final filteredCategories = allCategories.where((category) {
          return category.toLowerCase().contains(query);
        }).toList();

        // Si no hay categorías que coincidan, buscar productos
        if (filteredCategories.isEmpty) {
          return _buildProductSearchResults(searchProvider);
        }

        // Mostrar categorías filtradas
        final crossAxisCount = (MediaQuery.of(context).size.width ~/ 180).clamp(2, 4);
        
        return Column(
          children: [
            // Título de resultados
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Text(
                "Categorías encontradas (${filteredCategories.length})",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            // Grid de categorías filtradas
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: filteredCategories.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index) {
                  final category = filteredCategories[index];
                  return GestureDetector(
                    onTap: () {
                      final expressProvider = Provider.of<ExpressProvider>(context, listen: false);
                      if (expressProvider.customViewActive) {
                        context.push('/products-custom/$category');
                      } else {
                        context.push('/products/$category');
                      }
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.category,
                            size: 48,
                            color: Colors.blueAccent,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            category.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Construye los resultados de búsqueda de productos
  Widget _buildProductSearchResults(SearchProvider searchProvider) {
    if (searchProvider.isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (searchProvider.filteredProducts.isEmpty) {
      return const Center(
        child: Text(
          'No se encontraron resultados con ese término',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    final products = searchProvider.filteredProducts;
    final columns = (MediaQuery.of(context).size.width ~/ 180).clamp(2, 4);

    return Column(
      children: [
        // Título de resultados
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Text(
            "Productos encontrados (${products.length})",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        // Lista de productos
        Expanded(
          child: GridView.builder(
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
              final isExpressMode = Provider.of<ExpressProvider>(context, listen: false).isExpressModeActive;
              
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
                              color: isExpressMode 
                                  ? Colors.blue.shade600 
                                  : const Color.fromARGB(255, 255, 10, 10),
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
                          // Aquí puedes agregar el widget de cantidad si quieres
                          // SimpleQuantityButtons o CustomQuantityInput
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<ExpressProvider, ProductProvider, SearchProvider>(
      builder: (context, expressProvider, productProvider, searchProvider, child) {
        final isExpressMode = expressProvider.isExpressModeActive;
        final customViewActive = expressProvider.customViewActive;
        final totalItems = productProvider.totalItems;
        final buttonColor = isExpressMode ? Colors.blue : Colors.orange;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                customViewActive ? Icons.remove_red_eye : Icons.visibility_off,
                color: Colors.black,
              ),
              onPressed: () => expressProvider.toggleCustomView(),
            ),
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
            centerTitle: true,
            backgroundColor: const Color.fromARGB(255, 255, 238, 0),
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
                    if (totalItems > 0)
                      Positioned(
                        left: 25,
                        bottom: 26,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: buttonColor,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            totalItems < 99 ? totalItems.toString() : "99+",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
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
                      color: Color.fromARGB(255, 255, 238, 0),
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
                      color: Color.fromARGB(255, 255, 238, 0),
                      size: 18,
                    ),
                  ],
                ),
              ),
              // Título de categorías
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.grey[100],
                child: Text(
                  "Categorías${customViewActive ? " Custom" : ""}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              // Express mode switch
              if (expressProvider.showSwitch) ...[
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: ExpressModeSwitch(),
                ),
              ],
              // Contenido principal
              Expanded(
                child: searchProvider.searchQuery.isNotEmpty
                    ? _buildSearchResults(searchProvider)
                    : _buildCategoriesGrid(),
              ),
            ],
          ),
        );
      },
    );
  }
}
