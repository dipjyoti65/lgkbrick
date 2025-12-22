import 'package:flutter/foundation.dart';
import '../../core/exceptions/app_exception.dart';
import '../../core/services/network_service.dart';
import '../../core/utils/network_error_handler.dart';

/// Mixin for providers that need network awareness and error handling
/// 
/// Provides common functionality for handling network errors, loading states,
/// and user feedback in a consistent way across all providers.
mixin NetworkAwareProvider on ChangeNotifier {
  final NetworkService _networkService = NetworkService();
  
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  bool get hasError => _error != null;
  bool get hasSuccess => _successMessage != null;
  bool get isConnected => _networkService.isConnected;

  /// Execute operation with loading state and error handling
  Future<T?> executeOperation<T>(
    Future<T> Function() operation, {
    String? loadingMessage,
    String? successMessage,
    String? errorContext,
    bool clearPreviousError = true,
    bool clearPreviousSuccess = true,
    bool showLoadingState = true,
  }) async {
    if (clearPreviousError) _clearError();
    if (clearPreviousSuccess) _clearSuccessMessage();
    
    if (showLoadingState) _setLoading(true);

    try {
      // Check network connectivity
      if (!_networkService.isConnected) {
        throw NetworkException('No internet connection available');
      }

      final result = await operation();
      
      if (successMessage != null) {
        _setSuccessMessage(successMessage);
      }
      
      if (showLoadingState) _setLoading(false);
      return result;
    } catch (error) {
      _setError(_getErrorMessage(error, errorContext));
      if (showLoadingState) _setLoading(false);
      return null;
    }
  }

  /// Execute operation with retry logic
  Future<T?> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
    String? loadingMessage,
    String? successMessage,
    String? errorContext,
  }) async {
    _clearError();
    _clearSuccessMessage();
    _setLoading(true);

    try {
      final result = await _networkService.executeWithRetry(
        operation,
        maxRetries: maxRetries,
        retryDelay: retryDelay,
      );
      
      if (successMessage != null) {
        _setSuccessMessage(successMessage);
      }
      
      _setLoading(false);
      return result;
    } catch (error) {
      _setError(_getErrorMessage(error, errorContext));
      _setLoading(false);
      return null;
    }
  }

  /// Execute multiple operations concurrently
  Future<List<T?>> executeConcurrent<T>(
    List<Future<T> Function()> operations, {
    String? loadingMessage,
    String? successMessage,
    String? errorContext,
  }) async {
    _clearError();
    _clearSuccessMessage();
    _setLoading(true);

    try {
      final futures = operations.map((op) => op()).toList();
      final results = await Future.wait(
        futures,
        eagerError: false,
      );
      
      if (successMessage != null) {
        _setSuccessMessage(successMessage);
      }
      
      _setLoading(false);
      return results;
    } catch (error) {
      _setError(_getErrorMessage(error, errorContext));
      _setLoading(false);
      return List.filled(operations.length, null);
    }
  }

  /// Handle network error with appropriate user feedback
  void handleNetworkError(dynamic error, [String? context]) {
    final message = _getErrorMessage(error, context);
    _setError(message);
  }

  /// Check if current error is network-related
  bool get isNetworkError {
    if (_error == null) return false;
    return NetworkErrorHandler.isNetworkError(_error);
  }

  /// Check if current error should allow retry
  bool get shouldRetry {
    if (_error == null) return false;
    return NetworkErrorHandler.shouldRetry(_error);
  }

  /// Get connectivity status description
  String get connectivityDescription => _networkService.getConnectivityDescription();

  // State management methods

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void _setSuccessMessage(String message) {
    _successMessage = message;
    notifyListeners();
  }

  void _clearSuccessMessage() {
    _successMessage = null;
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error, [String? context]) {
    final baseMessage = NetworkErrorHandler.getUserMessage(error);
    return context != null ? '$context: $baseMessage' : baseMessage;
  }

  // Public methods for manual state management

  /// Clear error message
  void clearError() {
    _clearError();
    notifyListeners();
  }

  /// Clear success message
  void clearSuccessMessage() {
    _clearSuccessMessage();
    notifyListeners();
  }

  /// Set custom error message
  void setError(String message) {
    _setError(message);
  }

  /// Set custom success message
  void setSuccessMessage(String message) {
    _setSuccessMessage(message);
  }

  /// Refresh data with loading state
  Future<void> refresh(Future<void> Function() refreshOperation) async {
    await executeOperation(
      refreshOperation,
      loadingMessage: 'Refreshing...',
      errorContext: 'Failed to refresh data',
    );
  }

  /// Retry last failed operation
  Future<T?> retryOperation<T>(
    Future<T> Function() operation, {
    String? successMessage,
    String? errorContext,
  }) async {
    return await executeOperation(
      operation,
      successMessage: successMessage,
      errorContext: errorContext ?? 'Retry failed',
    );
  }
}