import 'package:flutter/foundation.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../data/models/product.dart';

/// Provider para la funcionalidad del carrito normal
/// Gestiona los productos en el carrito estándar
class CarritoProvider extends ChangeNotifier {
  final CartRepositoryImpl _cartRepository;

  CarritoProvider(this._cartRepository);

  // Getters para acceder al estado del carrito
  Map<Product, int> get items => _cartRepository.items;
  int get totalItems => _cartRepository.totalItems;
  double get totalPrice => _cartRepository.totalPrice;

  /// Agrega un producto al carrito normal
  void addItem(Product product, [int quantity = 1]) {
    _cartRepository.addItem(product, quantity);
    notifyListeners();
  }

  /// Remueve un producto del carrito normal
  void removeItem(Product product) {
    _cartRepository.removeItem(product);
    notifyListeners();
  }

  /// Obtiene la cantidad de un producto en el carrito normal
  int getQuantity(Product product) {
    return _cartRepository.getQuantity(product);
  }

  /// Limpia el carrito normal
  void clear() {
    _cartRepository.clear();
    notifyListeners();
  }
}
