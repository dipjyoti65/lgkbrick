import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../exceptions/app_exception.dart';
import '../services/network_service.dart';
import '../../presentation/widgets/feedback_manager.dart';

/// Network error handler utility class
/// 
/// Provides centralized network error handling with user-friendly messages,
/// retry mechanisms, and appropriate UI feedback.
class NetworkErrorHandler {
  static final NetworkService _networkService = NetworkService();

  /// Handle network error and show appropriate user feedback
  static void handleError(
    BuildContext context,
    dynamic error, {
    VoidCallback? onRetry,
    bool showSnackBar = true,
    String? customMessage,
  }) {
    final errorInfo = _analyzeError(error);
    
    if (showSnackBar) {
      if (errorInfo.isNetworkError && onRetry != null) {
        FeedbackManager.showNetworkError(
          context,
          message: customMessage ?? errorInfo.userMessage,
          onRetry: onRetry,
        );
      } else {
        FeedbackManager.showError(
          context,
          customMessage ?? errorInfo.userMessage,
        );
      }
    }
  }

  /// Get user-friendly error message from any error type
  static String getUserMessage(dynamic error) {
    return _analyzeError(error).userMessage;
  }

  /// Check if error is network-related
  static bool isNetworkError(dynamic error) {
    return _analyzeError(error).isNetworkError;
  }

  /// Check if error should trigger retry mechanism
  static bool shouldRetry(dynamic error) {
    return _analyzeError(error).shouldRetry;
  }

  /// Show network error dialog with retry option
  static Future<bool> showNetworkErrorDialog(
    BuildContext context,
    dynamic error, {
    VoidCallback? onRetry,
    String? title,
    String? customMessage,
  }) async {
    final errorInfo = _analyzeError(error);
    
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              errorInfo.isNetworkError ? Icons.wifi_off : Icons.error_outline,
              color: Colors.red.shade600,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title ?? (errorInfo.isNetworkError ? 'Connection Error' : 'Error'),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(customMessage ?? errorInfo.userMessage),
            if (errorInfo.isNetworkError) ...[
              const SizedBox(height: 12),
              Text(
                'Current status: ${_networkService.getConnectivityDescription()}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          if (onRetry != null && errorInfo.shouldRetry)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                onRetry();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
              ),
              child: const Text('Retry'),
            ),
        ],
      ),
    ) ?? false;
  }

  /// Execute operation with automatic network error handling
  static Future<T?> executeWithErrorHandling<T>(
    BuildContext context,
    Future<T> Function() operation, {
    String? loadingMessage,
    String? successMessage,
    String? errorMessage,
    bool showLoading = false,
    bool showSuccess = false,
    bool showError = true,
    int maxRetries = 2,
  }) async {
    int attempts = 0;
    
    while (attempts <= maxRetries) {
      try {
        if (showLoading && loadingMessage != null && attempts == 0) {
          FeedbackManager.showLoading(context, loadingMessage);
        }

        final result = await operation();

        if (showSuccess && successMessage != null) {
          FeedbackManager.showSuccess(context, successMessage);
        }

        return result;
      } catch (error) {
        attempts++;
        
        if (attempts > maxRetries || !shouldRetry(error)) {
          if (showError) {
            handleError(
              context,
              error,
              customMessage: errorMessage,
              onRetry: attempts <= maxRetries ? () {
                executeWithErrorHandling(
                  context,
                  operation,
                  loadingMessage: loadingMessage,
                  successMessage: successMessage,
                  errorMessage: errorMessage,
                  showLoading: showLoading,
                  showSuccess: showSuccess,
                  showError: showError,
                  maxRetries: maxRetries - attempts,
                );
              } : null,
            );
          }
          return null;
        }

        // Wait before retry
        await Future.delayed(Duration(seconds: attempts));
      }
    }
    
    return null;
  }

  /// Analyze error and return structured error information
  static _ErrorInfo _analyzeError(dynamic error) {
    // Network connectivity errors
    if (error is NetworkConnectivityException) {
      return _ErrorInfo(
        userMessage: error.message,
        isNetworkError: true,
        shouldRetry: true,
        errorType: _ErrorType.connectivity,
      );
    }

    // App-specific network errors
    if (error is NetworkException) {
      return _ErrorInfo(
        userMessage: error.message,
        isNetworkError: true,
        shouldRetry: true,
        errorType: _ErrorType.network,
      );
    }

    // Authentication errors
    if (error is AuthenticationException) {
      return _ErrorInfo(
        userMessage: error.message,
        isNetworkError: false,
        shouldRetry: false,
        errorType: _ErrorType.authentication,
      );
    }

    // Validation errors
    if (error is ValidationException) {
      return _ErrorInfo(
        userMessage: error.message,
        isNetworkError: false,
        shouldRetry: false,
        errorType: _ErrorType.validation,
      );
    }

    // Server errors
    if (error is ServerException) {
      return _ErrorInfo(
        userMessage: error.message,
        isNetworkError: false,
        shouldRetry: true,
        errorType: _ErrorType.server,
      );
    }

    // Dio errors
    if (error is DioException) {
      return _analyzeDioError(error);
    }

    // Generic app exceptions
    if (error is AppException) {
      return _ErrorInfo(
        userMessage: error.message,
        isNetworkError: false,
        shouldRetry: false,
        errorType: _ErrorType.generic,
      );
    }

    // Unknown errors
    return _ErrorInfo(
      userMessage: 'An unexpected error occurred. Please try again.',
      isNetworkError: false,
      shouldRetry: true,
      errorType: _ErrorType.unknown,
    );
  }

  /// Analyze Dio-specific errors
  static _ErrorInfo _analyzeDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return _ErrorInfo(
          userMessage: 'Connection timed out. Please check your internet connection and try again.',
          isNetworkError: true,
          shouldRetry: true,
          errorType: _ErrorType.timeout,
        );

      case DioExceptionType.connectionError:
        return _ErrorInfo(
          userMessage: _networkService.getNetworkErrorMessage(error),
          isNetworkError: true,
          shouldRetry: true,
          errorType: _ErrorType.connectivity,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        if (statusCode >= 500) {
          return _ErrorInfo(
            userMessage: 'Server error occurred. Please try again later.',
            isNetworkError: false,
            shouldRetry: true,
            errorType: _ErrorType.server,
          );
        } else if (statusCode == 401 || statusCode == 403) {
          return _ErrorInfo(
            userMessage: 'Authentication failed. Please login again.',
            isNetworkError: false,
            shouldRetry: false,
            errorType: _ErrorType.authentication,
          );
        } else {
          return _ErrorInfo(
            userMessage: 'Request failed. Please try again.',
            isNetworkError: false,
            shouldRetry: false,
            errorType: _ErrorType.client,
          );
        }

      case DioExceptionType.cancel:
        return _ErrorInfo(
          userMessage: 'Request was cancelled.',
          isNetworkError: false,
          shouldRetry: false,
          errorType: _ErrorType.cancelled,
        );

      case DioExceptionType.badCertificate:
        return _ErrorInfo(
          userMessage: 'Security certificate error. Please check your connection.',
          isNetworkError: true,
          shouldRetry: false,
          errorType: _ErrorType.security,
        );

      case DioExceptionType.unknown:
        return _ErrorInfo(
          userMessage: 'Network error occurred. Please try again.',
          isNetworkError: true,
          shouldRetry: true,
          errorType: _ErrorType.unknown,
        );
    }
  }

  /// Get appropriate retry delay based on attempt number
  static Duration getRetryDelay(int attempt) {
    // Exponential backoff: 1s, 2s, 4s, 8s, max 30s
    final seconds = (1 << (attempt - 1)).clamp(1, 30);
    return Duration(seconds: seconds);
  }

  /// Check if device has internet connectivity
  static bool get hasConnectivity => _networkService.isConnected;

  /// Get current connectivity description
  static String get connectivityDescription => _networkService.getConnectivityDescription();
}

/// Internal error information structure
class _ErrorInfo {
  final String userMessage;
  final bool isNetworkError;
  final bool shouldRetry;
  final _ErrorType errorType;

  _ErrorInfo({
    required this.userMessage,
    required this.isNetworkError,
    required this.shouldRetry,
    required this.errorType,
  });
}

/// Error type enumeration
enum _ErrorType {
  connectivity,
  network,
  timeout,
  authentication,
  validation,
  server,
  client,
  cancelled,
  security,
  generic,
  unknown,
}