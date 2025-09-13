import 'package:dio/dio.dart';
import '../models/producto.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: "https://fakestoreapi.com"));

  /// Obtener categorías
  Future<List<String>> getCategorias() async {
    final response = await _dio.get("/products/categories");
    return List<String>.from(response.data);
  }

  /// Obtener productos por categoría
  Future<List<Producto>> getProductsByCategory(String category) async {
    final response = await _dio.get(
      "/products/category/${Uri.encodeComponent(category)}",
    );
    return (response.data as List)
        .map((json) => Producto.fromJson(json))
        .toList();
  }

  /// Obtener todos los productos
  Future<List<Producto>> getAllProducts() async {
    final response = await _dio.get("/products");
    return (response.data as List)
        .map((json) => Producto.fromJson(json))
        .toList();
  }
}
