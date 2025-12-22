import 'package:dio/dio.dart';
import '../../core/exceptions/app_exception.dart';
import '../../core/services/network_service.dart';
import '../../core/utils/network_error_handler.dart';
import '../services/api_service.dart';

/// Base repository class with network error handling
/// 
/// Provides common functionality for all repositories including
/// network error handling, retry logic, and response processing.
abstract class BaseRepository {
  final ApiService apiService;
  final NetworkService _networkService = NetworkService();

  BaseRepository({required this.apiService});

  /// Execute API call with network error handling and retry logic
  Future<T> executeWithRetry<T>(
    Future<Response<T>> Function() apiCall, {
    int maxRetries = 3,
    Duration? retryDelay,
    bool Function(dynamic error)? shouldRetry,
  }) async {
    return await _networkService.executeWithRetry(
      () async {
        final response = await apiCall();
        return _processResponse(response);
      },
      maxRetries: maxRetries,
      retryDelay: retryDelay ?? const Duration(seconds: 2),
      shouldRetry: shouldRetry ?? _defaultShouldRetry,
    );
  }

  /// Process API response and extract data
  T _processResponse<T>(Response<T> response) {
    if (response.statusCode == null || response.statusCode! < 200 || response.statusCode! >= 300) {
      throw ServerException('Invalid response status: ${response.statusCode}');
    }

    if (response.data == null) {
      throw ServerException('No data received from server');
    }

    return response.data!;
  }

  /// Default retry logic for API errors
  bool _defaultShouldRetry(dynamic error) {
    return NetworkErrorHandler.shouldRetry(error);
  }

  /// Handle API errors and convert to appropriate app exceptions
  Never handleApiError(dynamic error, [String? context]) {
    if (error is DioException) {
      throw _convertDioException(error, context);
    } else if (error is AppException) {
      throw error;
    } else {
      throw AppException(
        context != null 
          ? '$context: ${error.toString()}'
          : error.toString()
      );
    }
  }

  /// Convert Dio exceptions to app exceptions
  AppException _convertDioException(DioException error, [String? context]) {
    final baseMessage = context != null ? '$context: ' : '';
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('${baseMessage}Connection timeout. Please check your internet connection.');

      case DioExceptionType.connectionError:
        return NetworkException('${baseMessage}No internet connection. Please check your network settings.');

      case DioExceptionType.badResponse:
        return _handleBadResponse(error, baseMessage);

      case DioExceptionType.cancel:
        return AppException('${baseMessage}Request was cancelled');

      case DioExceptionType.badCertificate:
        return NetworkException('${baseMessage}SSL certificate verification failed');

      case DioExceptionType.unknown:
        return NetworkException('${baseMessage}An unexpected network error occurred');
    }
  }

  /// Handle bad HTTP response errors
  AppException _handleBadResponse(DioException error, String baseMessage) {
    final response = error.response;
    if (response == null) {
      return ServerException('${baseMessage}No response from server');
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
        return ValidationException('$baseMessage$message', data);
      case 401:
        return AuthenticationException('${baseMessage}Authentication failed. Please login again.');
      case 403:
        return AuthenticationException('${baseMessage}You do not have permission to perform this action.');
      case 404:
        return AppException('${baseMessage}Resource not found');
      case 422:
        return ValidationException('$baseMessage$message', data);
      case 429:
        return AppException('${baseMessage}Too many requests. Please try again later.');
      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException('${baseMessage}Server error. Please try again later.');
      default:
        return AppException('$baseMessage$message');
    }
  }

  /// Check network connectivity before making API calls
  void ensureConnectivity() {
    if (!_networkService.isConnected) {
      throw NetworkException('No internet connection available');
    }
  }

  /// Get user-friendly error message
  String getErrorMessage(dynamic error) {
    return NetworkErrorHandler.getUserMessage(error);
  }

  /// Check if error is network-related
  bool isNetworkError(dynamic error) {
    return NetworkErrorHandler.isNetworkError(error);
  }
}