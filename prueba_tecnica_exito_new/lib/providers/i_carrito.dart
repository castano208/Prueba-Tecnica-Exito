import '../data/models/producto.dart';

abstract class ICarrito {
  Map<Producto, int> get items;
  int get totalItems;
  void addItem(Producto producto, [int cantidad = 1]);
  void removeItem(Producto producto);
  int getQuantity(Producto producto);
  void clear();
}
