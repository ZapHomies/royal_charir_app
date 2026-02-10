import 'package:dio/dio.dart';
import 'package:royal_charir_app/core/api/api_client.dart';
import 'package:royal_charir_app/core/api/api_config.dart';

/// Remote data source untuk Sync API
class SyncRemoteDataSource {
  final ApiClient apiClient;

  SyncRemoteDataSource({required this.apiClient});

  /// Get sync status dari server
  Future<Map<String, dynamic>> getSyncStatus() async {
    final response = await apiClient.get(ApiEndpoints.syncStatus);

    if (response.data['success'] == true) {
      return Map<String, dynamic>.from(response.data['data']);
    } else {
      throw Exception('Failed to get sync status: ${response.data['message']}');
    }
  }

  /// Export database
  Future<Map<String, dynamic>> exportDatabase({
    String type = 'Lunas', // full, products, orders, customers
    String format = 'json', // json, sql
    bool compress = true,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.syncExport,
      data: {
        'type': type,
        'format': format,
        'compress': compress,
      },
    );

    if (response.data['success'] == true) {
      return Map<String, dynamic>.from(response.data['data']);
    } else {
      throw Exception('Failed to export database: ${response.data['message']}');
    }
  }

  /// Import database
  Future<Map<String, dynamic>> importDatabase({
    required String filePath,
    String mode = 'merge', // merge or replace
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      'mode': mode,
    });

    final response = await apiClient.upload(
      ApiEndpoints.syncImport,
      formData,
    );

    if (response.data['success'] == true) {
      return Map<String, dynamic>.from(response.data['data']);
    } else {
      throw Exception('Failed to import database: ${response.data['message']}');
    }
  }

  /// Create backup
  Future<Map<String, dynamic>> createBackup() async {
    final response = await apiClient.post(ApiEndpoints.syncBackup);

    if (response.data['success'] == true) {
      return Map<String, dynamic>.from(response.data['data']);
    } else {
      throw Exception('Failed to create backup: ${response.data['message']}');
    }
  }

  /// Download file
  Future<void> downloadFile({
    required String filename,
    required String savePath,
    ProgressCallback? onProgress,
  }) async {
    await apiClient.download(
      ApiEndpoints.syncDownload(filename),
      savePath,
      onReceiveProgress: onProgress,
    );
  }
}

