import 'package:flutter/foundation.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository_impl.dart';

/// Provider para la funcionalidad de búsqueda
/// Gestiona la búsqueda de productos y el estado de filtros
class SearchProvider extends ChangeNotifier {
  final ProductRepositoryImpl _productRepository;
  
  String _searchQuery = '';
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isSearching = false;

  SearchProvider(this._productRepository);

  // Getters
  String get searchQuery => _searchQuery;
  List<Product> get filteredProducts => _filteredProducts;
  bool get isSearching => _isSearching;
  bool get hasResults => _filteredProducts.isNotEmpty;

  /// Establece la consulta de búsqueda y filtra los productos
  void setSearchQuery(String query) {
    _searchQuery = query;
    _filterProducts();
    notifyListeners();
  }

  /// Carga todos los productos para la búsqueda
  Future<void> loadAllProducts() async {
    try {
      _isSearching = true;
      notifyListeners();
      
      _allProducts = await _productRepository.getAllProducts();
      _filterProducts();
      
      _isSearching = false;
      notifyListeners();
    } catch (e) {
      print('Error al cargar productos para búsqueda: $e');
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Filtra los productos según la consulta de búsqueda
  void _filterProducts() {
    if (_searchQuery.isEmpty) {
      _filteredProducts = [];
      return;
    }

    final query = _searchQuery.toLowerCase();
    _filteredProducts = _allProducts.where((product) {
      return product.title.toLowerCase().contains(query) ||
             product.description.toLowerCase().contains(query) ||
             product.category.toLowerCase().contains(query);
    }).toList();
  }

  /// Limpia la búsqueda
  void clearSearch() {
    _searchQuery = '';
    _filteredProducts = [];
    notifyListeners();
  }

  /// Obtiene productos por categoría con filtro de búsqueda
  Future<List<Product>> getProductsByCategoryWithSearch(String category) async {
    try {
      final products = await _productRepository.getProductsByCategory(category);
      
      if (_searchQuery.isEmpty) {
        return products;
      }

      final query = _searchQuery.toLowerCase();
      return products.where((product) {
        return product.title.toLowerCase().contains(query) ||
               product.description.toLowerCase().contains(query);
      }).toList();
    } catch (e) {
      print('Error al buscar productos en categoría $category: $e');
      return [];
    }
  }
}
