import 'package:flutter/material.dart';
import '../data/models/producto.dart';
import 'i_carrito.dart';


class CarritoExpressProvider extends ChangeNotifier implements ICarrito {
  final Map<Producto, int> _items = {};

  @override
  Map<Producto, int> get items => Map.unmodifiable(_items);

  @override
  int get totalItems => _items.values.fold(0, (a, b) => a + b);

  @override
  void addItem(Producto producto, [int cantidad = 1]) {
    _items.update(
      producto,
      (v) => v + cantidad,
      ifAbsent: () => cantidad,
    );

    if (_items[producto]! <= 0) {
      _items.remove(producto);
    }

    notifyListeners();
  }
  
  @override
  void removeItem(Producto producto) {
    if (!_items.containsKey(producto)) return;
    if (_items[producto]! > 1) {
      _items[producto] = _items[producto]! - 1;
    } else {
      _items.remove(producto);
    }
    notifyListeners();
  }

  @override
  int getQuantity(Producto producto) => _items[producto] ?? 0;

  @override
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
