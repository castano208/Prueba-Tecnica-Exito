import '../../data/models/product.dart';

/// Interfaz para operaciones de API
/// Define los métodos para comunicarse con servicios externos
abstract class IApiService {
  /// Obtiene todas las categorías desde la API
  Future<List<String>> getCategories();
  
  /// Obtiene productos por categoría desde la API
  Future<List<Product>> getProductsByCategory(String category);
  
  /// Obtiene todos los productos desde la API
  Future<List<Product>> getAllProducts();
  
  /// Obtiene un producto por ID desde la API
  Future<Product?> getProductById(int id);
}
