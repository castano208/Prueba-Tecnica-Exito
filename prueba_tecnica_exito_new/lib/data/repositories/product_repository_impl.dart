import 'package:flutter/foundation.dart';
import '../../core/interfaces/i_product_repository.dart';
import '../../core/interfaces/i_api_service.dart';
import '../models/product.dart';

/// Implementación del repositorio de productos
/// Gestiona el acceso a datos de productos a través del servicio de API
class ProductRepositoryImpl extends ChangeNotifier implements IProductRepository {
  final IApiService _apiService;

  ProductRepositoryImpl(this._apiService);

  @override
  Future<List<String>> getCategories() async {
    return await _apiService.getCategories();
  }

  @override
  Future<List<Product>> getProductsByCategory(String category) async {
    return await _apiService.getProductsByCategory(category);
  }

  @override
  Future<List<Product>> getAllProducts() async {
    return await _apiService.getAllProducts();
  }

  @override
  Future<Product?> getProductById(int id) async {
    return await _apiService.getProductById(id);
  }
}
