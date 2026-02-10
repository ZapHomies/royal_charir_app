/// API Client Configuration
class ApiConfig {
  ApiConfig._();

  // Base URL - Ganti dengan URL server Laravel Anda
  static const String baseUrl = 'http://localhost:8000'; // Untuk development
  // static const String baseUrl = 'http://192.168.1.100:8000'; // Untuk testing di network lokal
  // static const String baseUrl = 'https://your-domain.com'; // Untuk production

  static const String apiVersion = 'v1';
  static const String apiPrefix = '/api/$apiVersion';

  // Timeout
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPerPage = 50;
  static const int maxPerPage = 100;

  // Retry
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
}

/// API Endpoints Constants
class ApiEndpoints {
  ApiEndpoints._();

  // Products
  static const String productsList = '${ApiConfig.apiPrefix}/products';
  static String productDetail(String uuid) =>
      '${ApiConfig.apiPrefix}/products/$uuid';
  static const String productCreate = '${ApiConfig.apiPrefix}/products';
  static String productUpdate(String uuid) =>
      '${ApiConfig.apiPrefix}/products/$uuid';
  static String productDelete(String uuid) =>
      '${ApiConfig.apiPrefix}/products/$uuid';
  static const String productBatchSync =
      '${ApiConfig.apiPrefix}/products/batch-sync';

  // Customers
  static const String customersList = '${ApiConfig.apiPrefix}/customers';
  static String customerDetail(String uuid) =>
      '${ApiConfig.apiPrefix}/customers/$uuid';
  static const String customerCreate = '${ApiConfig.apiPrefix}/customers';
  static String customerUpdate(String uuid) =>
      '${ApiConfig.apiPrefix}/customers/$uuid';
  static String customerDelete(String uuid) =>
      '${ApiConfig.apiPrefix}/customers/$uuid';
  static const String customerBatchSync =
      '${ApiConfig.apiPrefix}/customers/batch-sync';

  // Orders
  static const String ordersList = '${ApiConfig.apiPrefix}/orders';
  static String orderDetail(String uuid) =>
      '${ApiConfig.apiPrefix}/orders/$uuid';
  static const String orderCreate = '${ApiConfig.apiPrefix}/orders';
  static const String orderBatchSync =
      '${ApiConfig.apiPrefix}/orders/batch-sync';

  // Sync
  static const String syncStatus = '${ApiConfig.apiPrefix}/sync/status';
  static const String syncExport = '${ApiConfig.apiPrefix}/sync/export';
  static const String syncImport = '${ApiConfig.apiPrefix}/sync/import';
  static const String syncBackup = '${ApiConfig.apiPrefix}/sync/backup';
  static String syncDownload(String filename) =>
      '${ApiConfig.apiPrefix}/sync/download/$filename';
}
