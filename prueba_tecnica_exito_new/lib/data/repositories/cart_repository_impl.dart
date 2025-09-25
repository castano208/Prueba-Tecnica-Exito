import 'package:flutter/foundation.dart';
import '../../core/interfaces/i_cart_repository.dart';
import '../models/product.dart';

/// Implementación del repositorio del carrito
/// Gestiona el estado y las operaciones del carrito de compras
class CartRepositoryImpl extends ChangeNotifier implements ICartRepository {
  final Map<Product, int> _items = {};

  @override
  Map<Product, int> get items => Map.unmodifiable(_items);

  @override
  int get totalItems => _items.values.fold(0, (a, b) => a + b);

  @override
  double get totalPrice {
    double total = 0.0;
    _items.forEach((product, quantity) {
      total += product.price * quantity;
    });
    return total;
  }

  @override
  void addItem(Product product, [int quantity = 1]) {
    _items.update(
      product,
      (v) => v + quantity,
      ifAbsent: () => quantity,
    );

    if (_items[product]! <= 0) {
      _items.remove(product);
    }

    notifyListeners();
  }

  @override
  void removeItem(Product product) {
    if (!_items.containsKey(product)) return;
    if (_items[product]! > 1) {
      _items[product] = _items[product]! - 1;
    } else {
      _items.remove(product);
    }
    notifyListeners();
  }

  @override
  int getQuantity(Product product) => _items[product] ?? 0;

  @override
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
