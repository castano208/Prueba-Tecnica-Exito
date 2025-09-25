import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../../core/interfaces/i_api_service.dart';

/// Implementación del servicio de API usando Dio
/// Se encarga de comunicarse con la API externa para obtener datos de productos
class ApiServiceImpl extends ChangeNotifier implements IApiService {
  final Dio _dio;

  ApiServiceImpl({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(baseUrl: "https://fakestoreapi.com"));

  /// Obtiene todas las categorías disponibles desde la API
  @override
  Future<List<String>> getCategories() async {
    try {
      final response = await _dio.get("/products/categories");
      return List<String>.from(response.data);
    } catch (e) {
      throw Exception('Error al obtener categorías: $e');
    }
  }

  /// Obtiene productos por categoría desde la API
  @override
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final response = await _dio.get(
        "/products/category/${Uri.encodeComponent(category)}",
      );
      return (response.data as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener productos para la categoría $category: $e');
    }
  }

  /// Obtiene todos los productos desde la API
  @override
  Future<List<Product>> getAllProducts() async {
    try {
      final response = await _dio.get("/products");
      return (response.data as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener todos los productos: $e');
    }
  }

  /// Obtiene un producto específico por su ID desde la API
  @override
  Future<Product?> getProductById(int id) async {
    try {
      final response = await _dio.get("/products/$id");
      return Product.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al obtener el producto con ID $id: $e');
    }
  }
}
