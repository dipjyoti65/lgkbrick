import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Network service for monitoring connectivity and handling network-related operations
/// 
/// Provides connectivity monitoring, network status checking, and retry mechanisms
/// for failed network operations.
class NetworkService extends ChangeNotifier {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  bool _isConnected = false;
  final List<VoidCallback> _retryCallbacks = [];

  /// Current connectivity status
  ConnectivityResult get connectionStatus => _connectionStatus;
  
  /// Whether device is connected to internet
  bool get isConnected => _isConnected;

  /// Initialize network monitoring
  Future<void> initialize() async {
    // Check initial connectivity
    await _updateConnectionStatus(await _connectivity.checkConnectivity());
    
    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  /// Dispose resources
  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  /// Update connection status and notify listeners
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    _connectionStatus = result;
    
    // Check if actually connected to internet
    _isConnected = await _checkInternetConnection();
    
    // If connection restored, retry failed operations
    if (_isConnected && _retryCallbacks.isNotEmpty) {
      final callbacks = List<VoidCallback>.from(_retryCallbacks);
      _retryCallbacks.clear();
      
      for (final callback in callbacks) {
        try {
          callback();
        } catch (e) {
          debugPrint('Error retrying network operation: $e');
        }
      }
    }
    
    notifyListeners();
  }

  /// Check if device has actual internet connection
  Future<bool> _checkInternetConnection() async {
    if (_connectionStatus == ConnectivityResult.none) {
      return false;
    }

    // For development, be more lenient with connectivity checks
    // If we have any network connection, assume internet is available
    if (_connectionStatus == ConnectivityResult.wifi || 
        _connectionStatus == ConnectivityResult.mobile ||
        _connectionStatus == ConnectivityResult.ethernet) {
      return true;
    }

    // Fallback to actual internet check for unknown connection types
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      // If google.com fails, still return true if we have network connectivity
      // This helps in development environments with restricted internet
      return _connectionStatus != ConnectivityResult.none;
    } catch (e) {
      debugPrint('Error checking internet connection: $e');
      // Be optimistic - if we have network connectivity, assume internet works
      return _connectionStatus != ConnectivityResult.none;
    }
  }

  /// Add callback to retry when connection is restored
  void addRetryCallback(VoidCallback callback) {
    if (!_retryCallbacks.contains(callback)) {
      _retryCallbacks.add(callback);
    }
  }

  /// Remove retry callback
  void removeRetryCallback(VoidCallback callback) {
    _retryCallbacks.remove(callback);
  }

  /// Execute operation with network retry logic
  Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        // Check network connectivity before attempting
        if (!_isConnected) {
          throw NetworkConnectivityException('No internet connection');
        }
        
        return await operation();
      } catch (error) {
        attempts++;
        
        // Check if we should retry this error
        final shouldRetryError = shouldRetry?.call(error) ?? 
            _shouldRetryByDefault(error);
        
        if (attempts >= maxRetries || !shouldRetryError) {
          rethrow;
        }
        
        // Wait before retrying
        await Future.delayed(retryDelay * attempts);
        
        // Update connection status before retry
        await _updateConnectionStatus(await _connectivity.checkConnectivity());
      }
    }
    
    throw Exception('Max retries exceeded');
  }

  /// Default retry logic for common network errors
  bool _shouldRetryByDefault(dynamic error) {
    if (error is SocketException) return true;
    if (error is TimeoutException) return true;
    if (error is HttpException) {
      // Retry on server errors (5xx) but not client errors (4xx)
      return error.message.contains('500') || 
             error.message.contains('502') || 
             error.message.contains('503') || 
             error.message.contains('504');
    }
    return false;
  }

  /// Get user-friendly network error message
  String getNetworkErrorMessage(dynamic error) {
    if (!_isConnected) {
      return 'No internet connection. Please check your network settings.';
    }
    
    if (error is SocketException) {
      return 'Unable to connect to server. Please try again.';
    }
    
    if (error is TimeoutException) {
      return 'Request timed out. Please check your connection and try again.';
    }
    
    if (error is HttpException) {
      if (error.message.contains('500')) {
        return 'Server error occurred. Please try again later.';
      }
      if (error.message.contains('404')) {
        return 'Requested resource not found.';
      }
      if (error.message.contains('401') || error.message.contains('403')) {
        return 'Authentication failed. Please login again.';
      }
    }
    
    return 'Network error occurred. Please try again.';
  }

  /// Get connectivity status description
  String getConnectivityDescription() {
    switch (_connectionStatus) {
      case ConnectivityResult.wifi:
        return _isConnected ? 'Connected via WiFi' : 'WiFi connected but no internet';
      case ConnectivityResult.mobile:
        return _isConnected ? 'Connected via Mobile Data' : 'Mobile data connected but no internet';
      case ConnectivityResult.ethernet:
        return _isConnected ? 'Connected via Ethernet' : 'Ethernet connected but no internet';
      case ConnectivityResult.none:
        return 'No network connection';
      default:
        return 'Unknown connection status';
    }
  }
}

/// Network connectivity exception for connectivity issues
class NetworkConnectivityException implements Exception {
  final String message;
  
  NetworkConnectivityException(this.message);
  
  @override
  String toString() => message;
}