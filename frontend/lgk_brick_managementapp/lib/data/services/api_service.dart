import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/exceptions/app_exception.dart';
import '../../core/services/network_service.dart';
import '../../core/services/security_service.dart';

/// Generic HTTP client with interceptors for authentication and error handling
class ApiService {
  late final Dio _dio;
  String? _authToken;
  final NetworkService _networkService = NetworkService();
  static const bool _isDebugMode = true; // Set to false for production

  ApiService({String? baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupSecureConnection();
    _setupInterceptors();
  }

  /// Set up secure HTTPS connection with certificate validation
  void _setupSecureConnection() {
    // Only configure HTTP client for mobile platforms (not web)
    if (_dio.httpClientAdapter is IOHttpClientAdapter) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        
        // For development with HTTP localhost, allow insecure connections
        // In production, this should be configured to enforce HTTPS
        final baseUrl = _dio.options.baseUrl;
        final isDevelopment = baseUrl.contains('localhost') || baseUrl.contains('10.0.2.2');
        
        client.badCertificateCallback = (cert, host, port) {
          // Allow self-signed certificates in development
          return isDevelopment;
        };
        
        // Set connection timeouts
        client.connectionTimeout = const Duration(seconds: 10);
        client.idleTimeout = const Duration(seconds: 30);
        
        return client;
      };
    }
    // For web platform, the browser handles HTTPS connections automatically
  }

  /// Set up interceptors for authentication and error handling
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Inject authentication token if available
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          
          // Log request securely (without sensitive data)
          SecurityService.secureLog(
            'API Request: ${options.method} ${options.baseUrl}${options.path}'
          );
          
          if (_isDebugMode) {
            print('DEBUG: Making request to ${options.baseUrl}${options.path}');
            print('DEBUG: Headers: ${options.headers}');
          }
          
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (_isDebugMode) {
            print('DEBUG: API Error - Type: ${error.type}');
            print('DEBUG: API Error - Message: ${error.message}');
            print('DEBUG: API Error - Response: ${error.response?.statusCode}');
          }
          
          // Handle authentication failures securely
          if (error.response?.statusCode == 401) {
            // Clear token on authentication failure
            clearAuthToken();
            
            // Log authentication failure securely
            SecurityService.secureLog(
              'Authentication failure detected - token cleared'
            );
            
            // Notify about authentication failure
            final authException = AuthenticationException(
              'Authentication failed. Please login again.'
            );
            
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: authException,
                type: DioExceptionType.badResponse,
                response: error.response,
              ),
            );
          }
          
          // Transform other Dio errors to app exceptions
          final appException = _handleError(error);
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: appException,
              type: error.type,
            ),
          );
        },
      ),
    );

    // Add retry interceptor for transient errors
    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onError: (error, handler) async {
          if (_shouldRetry(error)) {
            try {
              final response = await _retry(error.requestOptions);
              return handler.resolve(response);
            } catch (e) {
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Set authentication token for API requests
  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Clear authentication token
  void clearAuthToken() {
    _authToken = null;
  }

  /// Validate that the API is using HTTPS for secure communication
  bool isUsingSecureConnection() {
    final baseUrl = _dio.options.baseUrl;
    return baseUrl.startsWith('https://');
  }

  /// Get the current base URL for security validation
  String getBaseUrl() {
    return _dio.options.baseUrl;
  }

  /// GET request with network retry logic
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    // For development, skip network service retry and make direct requests
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _extractException(e);
    }
  }

  /// POST request with network retry logic
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    // For development, skip network service retry and make direct requests
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _extractException(e);
    }
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _extractException(e);
    }
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _extractException(e);
    }
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _extractException(e);
    }
  }

  /// Download file
  Future<Response> downloadFile(
    String path,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.download(
        path,
        savePath,
        queryParameters: queryParameters,
        options: options,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _extractException(e);
    }
  }

  /// Upload file
  Future<Response<T>> uploadFile<T>(
    String path,
    FormData formData, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: options,
        onSendProgress: onSendProgress,
      );
    } on DioException catch (e) {
      throw _extractException(e);
    }
  }

  /// Check if error should be retried
  bool _shouldRetry(DioException error) {
    // Retry on network errors and 5xx server errors
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        (error.response?.statusCode != null &&
            error.response!.statusCode! >= 500);
  }

  /// Retry failed request
  Future<Response> _retry(RequestOptions requestOptions) async {
    // Wait before retrying
    await Future.delayed(const Duration(seconds: 2));

    // Create new options from request options
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );

    // Retry the request
    return await _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  /// Handle Dio errors and transform to app exceptions
  AppException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          'Connection timeout. Please check your internet connection.',
        );

      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);

      case DioExceptionType.cancel:
        return AppException('Request was cancelled');

      case DioExceptionType.connectionError:
        // Be more specific about connection errors
        final errorMsg = error.message?.toLowerCase() ?? '';
        if (errorMsg.contains('10.0.2.2') || errorMsg.contains('connection refused')) {
          return NetworkException(
            'Cannot connect to server. Make sure the backend is running on port 8000.',
          );
        }
        if (errorMsg.contains('network is unreachable')) {
          return NetworkException(
            'Network unreachable. Check your internet connection.',
          );
        }
        return NetworkException(
          'Connection failed. Please check your network and try again.',
        );

      case DioExceptionType.badCertificate:
        return NetworkException(
          'SSL certificate verification failed. The connection is not secure.'
        );

      case DioExceptionType.unknown:
        return NetworkException(
          'An unexpected error occurred. Please try again.',
        );
    }
  }

  /// Handle HTTP response errors
  AppException _handleResponseError(Response? response) {
    if (response == null) {
      return AppException('No response from server');
    }

    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    // Extract error message from response
    String message = 'An error occurred';
    if (data is Map<String, dynamic>) {
      message = data['message'] ?? message;
    }

    switch (statusCode) {
      case 400:
        return ValidationException(message, data);
      case 401:
        return AuthenticationException('Authentication failed. Please login again.');
      case 403:
        return AuthenticationException('You do not have permission to perform this action.');
      case 404:
        return AppException('Resource not found');
      case 422:
        return ValidationException(message, data);
      case 500:
      case 502:
      case 503:
        return ServerException('Server error. Please try again later.');
      default:
        return AppException(message);
    }
  }

  /// Extract exception from DioException
  AppException _extractException(DioException error) {
    if (error.error is AppException) {
      return error.error as AppException;
    }
    return _handleError(error);
  }
}

//