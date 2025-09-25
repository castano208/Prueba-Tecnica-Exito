import '../../data/models/product.dart';

/// Interfaz para operaciones de datos de productos
/// Define los métodos para obtener información de productos y categorías
abstract class IProductRepository {
  /// Obtiene todas las categorías disponibles
  Future<List<String>> getCategories();
  
  /// Obtiene productos por categoría
  Future<List<Product>> getProductsByCategory(String category);
  
  /// Obtiene todos los productos
  Future<List<Product>> getAllProducts();
  
  /// Obtiene un producto por su ID
  Future<Product?> getProductById(int id);
}
