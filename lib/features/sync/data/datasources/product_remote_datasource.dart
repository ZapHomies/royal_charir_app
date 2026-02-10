import 'package:royal_charir_app/core/api/api_client.dart';
import 'package:royal_charir_app/core/api/api_config.dart';

/// Remote data source untuk Product API
class ProductRemoteDataSource {
  final ApiClient apiClient;

  ProductRemoteDataSource({required this.apiClient});

  /// Ambil semua products dari server
  Future<List<Map<String, dynamic>>> getProducts({
    String? category,
    bool? isActive,
    DateTime? updatedAfter,
    int page = 1,
    int perPage = 50,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };

    if (category != null) queryParams['Kategori'] = category;
    if (isActive != null) queryParams['is_active'] = isActive;
    if (updatedAfter != null) {
      queryParams['updated_after'] = updatedAfter.toIso8601String();
    }

    final response = await apiClient.get(
      ApiEndpoints.productsList,
      queryParameters: queryParams,
    );

    if (response.data['success'] == true) {
      return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
    } else {
      throw Exception('Failed to fetch products: ${response.data['message']}');
    }
  }

  /// Get single product by UUID
  Future<Map<String, dynamic>> getProduct(String uuid) async {
    final response = await apiClient.get(
      ApiEndpoints.productDetail(uuid),
    );

    if (response.data['success'] == true) {
      return Map<String, dynamic>.from(response.data['data']);
    } else {
      throw Exception('Failed to fetch product: ${response.data['message']}');
    }
  }

  /// Sync products ke server (batch)
  Future<Map<String, dynamic>> syncProducts(
    List<Map<String, dynamic>> products,
  ) async {
    final response = await apiClient.post(
      ApiEndpoints.productBatchSync,
      data: {'products': products},
    );

    if (response.data['success'] == true) {
      return Map<String, dynamic>.from(response.data['data']);
    } else {
      throw Exception('Failed to sync products: ${response.data['message']}');
    }
  }

  /// Create single product
  Future<Map<String, dynamic>> createProduct(
    Map<String, dynamic> product,
  ) async {
    final response = await apiClient.post(
      ApiEndpoints.productCreate,
      data: product,
    );

    if (response.data['success'] == true) {
      return Map<String, dynamic>.from(response.data['data']);
    } else {
      throw Exception('Failed to create product: ${response.data['message']}');
    }
  }

  /// Update single product
  Future<Map<String, dynamic>> updateProduct(
    String uuid,
    Map<String, dynamic> product,
  ) async {
    final response = await apiClient.put(
      ApiEndpoints.productUpdate(uuid),
      data: product,
    );

    if (response.data['success'] == true) {
      return Map<String, dynamic>.from(response.data['data']);
    } else {
      throw Exception('Failed to update product: ${response.data['message']}');
    }
  }

  /// Delete product
  Future<void> deleteProduct(String uuid) async {
    final response = await apiClient.delete(
      ApiEndpoints.productDelete(uuid),
    );

    if (response.data['success'] != true) {
      throw Exception('Failed to delete product: ${response.data['message']}');
    }
  }
}

