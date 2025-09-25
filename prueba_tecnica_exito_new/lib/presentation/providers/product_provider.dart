import 'package:flutter/foundation.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/models/product.dart';
import 'express_provider.dart';
import 'carrito_provider.dart';
import 'carrito_express_provider.dart';

/// Provider para la funcionalidad relacionada con productos
/// Gestiona la lógica de productos y determina qué carrito usar según el modo
class ProductProvider extends ChangeNotifier {
  final ProductRepositoryImpl _productRepository;
  final CarritoProvider _carritoProvider;
  final CarritoExpressProvider _carritoExpressProvider;
  final ExpressProvider _expressProvider;

  ProductProvider(
    this._productRepository,
    this._carritoProvider,
    this._carritoExpressProvider,
    this._expressProvider,
  );

  // Getters que devuelven el carrito activo según el modo
  Map<Product, int> get cartItems => _expressProvider.isExpressModeActive 
      ? _carritoExpressProvider.items 
      : _carritoProvider.items;
  int get totalItems => _expressProvider.isExpressModeActive 
      ? _carritoExpressProvider.totalItems 
      : _carritoProvider.totalItems;
  double get totalPrice => _expressProvider.isExpressModeActive 
      ? _carritoExpressProvider.totalPrice 
      : _carritoProvider.totalPrice;
  bool get isExpressModeActive => _expressProvider.isExpressModeActive;

  /// Obtiene todas las categorías disponibles
  Future<List<String>> getCategories() async {
    try {
      return await _productRepository.getCategories();
    } catch (e) {
      print('Error al obtener categorías: $e');
      return [];
    }
  }

  /// Obtiene productos por categoría
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      return await _productRepository.getProductsByCategory(category);
    } catch (e) {
      print('Error al obtener productos para la categoría $category: $e');
      return [];
    }
  }

  /// Agrega un producto al carrito (normal o express según el modo)
  void addToCart(Product product, [int quantity = 1]) {
    if (_expressProvider.isExpressModeActive) {
      _carritoExpressProvider.addItem(product, quantity);
    } else {
      _carritoProvider.addItem(product, quantity);
    }
    notifyListeners();
  }

  /// Remueve un producto del carrito (normal o express según el modo)
  void removeFromCart(Product product) {
    if (_expressProvider.isExpressModeActive) {
      _carritoExpressProvider.removeItem(product);
    } else {
      _carritoProvider.removeItem(product);
    }
    notifyListeners();
  }

  /// Obtiene la cantidad de un producto en el carrito activo
  int getProductQuantity(Product product) {
    return _expressProvider.isExpressModeActive 
        ? _carritoExpressProvider.getQuantity(product)
        : _carritoProvider.getQuantity(product);
  }

  /// Limpia el carrito activo
  void clearCart() {
    if (_expressProvider.isExpressModeActive) {
      _carritoExpressProvider.clear();
    } else {
      _carritoProvider.clear();
    }
    notifyListeners();
  }
}
