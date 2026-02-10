import 'package:royal_charir_app/core/api/api_client.dart';
import 'package:royal_charir_app/core/api/api_config.dart';

/// Remote data source untuk Order API
class OrderRemoteDataSource {
  final ApiClient apiClient;

  OrderRemoteDataSource({required this.apiClient});

  Future<List<Map<String, dynamic>>> getOrders({
    String? customerId,
    String? orderType,
    String? paymentStatus,
    DateTime? updatedAfter,
    int page = 1,
    int perPage = 50,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };

    if (customerId != null) queryParams['customer_id'] = customerId;
    if (orderType != null) queryParams['order_type'] = orderType;
    if (paymentStatus != null) queryParams['payment_status'] = paymentStatus;
    if (updatedAfter != null) {
      queryParams['updated_after'] = updatedAfter.toIso8601String();
    }

    final response = await apiClient.get(
      ApiEndpoints.ordersList,
      queryParameters: queryParams,
    );

    if (response.data['success'] == true) {
      return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
    } else {
      throw Exception('Failed to fetch orders: ${response.data['message']}');
    }
  }

  Future<Map<String, dynamic>> syncOrders(
    List<Map<String, dynamic>> orders,
  ) async {
    final response = await apiClient.post(
      ApiEndpoints.orderBatchSync,
      data: {'orders': orders},
    );

    if (response.data['success'] == true) {
      return Map<String, dynamic>.from(response.data['data']);
    } else {
      throw Exception('Failed to sync orders: ${response.data['message']}');
    }
  }
}
