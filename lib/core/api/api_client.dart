import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'api_config.dart';

/// HTTP Client menggunakan Dio
class ApiClient {
  late final Dio _dio;
  final Logger _logger = Logger();

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_loggingInterceptor());
    _dio.interceptors.add(_errorInterceptor());
  }

  /// Logging interceptor
  InterceptorsWrapper _loggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        _logger.d(
          'REQUEST[${options.method}] => PATH: ${options.path}\n'
          'Headers: ${options.headers}\n'
          'Data: ${options.data}',
        );
        return handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.i(
          'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}\n'
          'Data: ${response.data}',
        );
        return handler.next(response);
      },
      onError: (error, handler) {
        _logger.e(
          'ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}\n'
          'Message: ${error.message}\n'
          'Data: ${error.response?.data}',
        );
        return handler.next(error);
      },
    );
  }

  /// Error handling interceptor
  InterceptorsWrapper _errorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout) {
          _logger.w('Request timeout: ${error.requestOptions.path}');
        } else if (error.type == DioExceptionType.connectionError) {
          _logger.w('Connection error: Check your internet connection');
        }
        return handler.next(error);
      },
    );
  }

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Download file
  Future<Response> download(
    String path,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.download(
        path,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Upload file
  Future<Response> upload(
    String path,
    FormData formData, {
    ProgressCallback? onSendProgress,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
