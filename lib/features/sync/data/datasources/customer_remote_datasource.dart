import 'package:royal_charir_app/core/api/api_client.dart';
import 'package:royal_charir_app/core/api/api_config.dart';

/// Remote data source untuk Customer API
class CustomerRemoteDataSource {
  final ApiClient apiClient;

  CustomerRemoteDataSource({required this.apiClient});

  Future<List<Map<String, dynamic>>> getCustomers({
    String? customerType,
    bool? isActive,
    DateTime? updatedAfter,
    int page = 1,
    int perPage = 50,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };

    if (customerType != null) queryParams['customer_type'] = customerType;
    if (isActive != null) queryParams['is_active'] = isActive;
    if (updatedAfter != null) {
      queryParams['updated_after'] = updatedAfter.toIso8601String();
    }

    final response = await apiClient.get(
      ApiEndpoints.customersList,
      queryParameters: queryParams,
    );

    if (response.data['success'] == true) {
      return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
    } else {
      throw Exception('Failed to fetch customers: ${response.data['message']}');
    }
  }

  Future<Map<String, dynamic>> syncCustomers(
    List<Map<String, dynamic>> customers,
  ) async {
    final response = await apiClient.post(
      ApiEndpoints.customerBatchSync,
      data: {'customers': customers},
    );

    if (response.data['success'] == true) {
      return Map<String, dynamic>.from(response.data['data']);
    } else {
      throw Exception('Failed to sync customers: ${response.data['message']}');
    }
  }
}
