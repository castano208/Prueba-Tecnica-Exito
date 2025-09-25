import '../../data/models/product.dart';

/// Interfaz para operaciones del carrito de compras
/// Define los métodos necesarios para gestionar productos en el carrito
abstract class ICartRepository {
  /// Obtiene todos los productos en el carrito
  Map<Product, int> get items;
  
  /// Obtiene el número total de productos
  int get totalItems;
  
  /// Agrega un producto al carrito
  void addItem(Product product, [int quantity = 1]);
  
  /// Remueve un producto del carrito
  void removeItem(Product product);
  
  /// Obtiene la cantidad de un producto específico
  int getQuantity(Product product);
  
  /// Limpia todos los productos del carrito
  void clear();
  
  /// Obtiene el precio total de todos los productos
  double get totalPrice;
}
