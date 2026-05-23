// ═══════════════════════════════════════════════════════
//  data/product_repository.dart
//  Equivalente a ProductRepositoryImpl.kt
//  Usa Dio invece di Retrofit — la logica è identica
// ═══════════════════════════════════════════════════════

import 'package:dio/dio.dart';
import 'models/product.dart';

class ProductRepository {
  ProductRepository(this._dio);

  final Dio _dio;

  // Equivalente a getProductList() nel tuo repository
  Future<List<Product>> getProducts() async {
    final response = await _dio.get<List<dynamic>>('/products?limit=30');
    return (response.data ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .where((p) => p.images.isNotEmpty && p.category.name.isNotEmpty)
        .toList();
  }

  // Equivalente a getProductById() nel tuo repository
  Future<Product> getProductById(int id) async {
    final response = await _dio.get<Map<String, dynamic>>('/products/$id');
    return Product.fromJson(response.data!);
  }
}
