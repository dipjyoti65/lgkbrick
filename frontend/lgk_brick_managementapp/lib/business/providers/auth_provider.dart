import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/exceptions/app_exception.dart';
import '../../core/services/security_service.dart';

/// Provider for authentication state management
/// 
/// Manages user authentication state including login, logout, session management,
/// and automatic token refresh. Uses ChangeNotifier for reactive state updates.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  SecurityService? _securityService;

  // Authentication state
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  AuthProvider({
    required AuthRepository authRepository,
    SecurityService? securityService,
  }) : _authRepository = authRepository,
       _securityService = securityService;

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Set security service for session management
  void setSecurityService(SecurityService securityService) {
    _securityService = securityService;
  }

  /// Initialize authentication state on app startup
  /// 
  /// Checks for stored credentials and attempts to restore the session.
  /// If successful, sets the user as authenticated. If token is invalid,
  /// clears stored credentials.
  Future<void> initialize() async {
    _setLoading(true);
    _clearError();

    try {
      // Add timeout to prevent hanging - reduced to 3 seconds for faster startup
      final restored = await _authRepository.restoreSession()
          .timeout(const Duration(seconds: 3));
      
      if (restored) {
        _currentUser = await _authRepository.getStoredUser();
        _isAuthenticated = true;
        // Start security session tracking
        _securityService?.startSession();
        SecurityService.secureLog('Session restored successfully');
      } else {
        _isAuthenticated = false;
        _currentUser = null;
        SecurityService.secureLog('No valid session found');
      }
    } on TimeoutException catch (e) {
      _isAuthenticated = false;
      _currentUser = null;
      SecurityService.secureLog('Session restoration timed out', error: e);
    } catch (e) {
      _isAuthenticated = false;
      _currentUser = null;
      // Don't set error for initialization failures - just log them
      SecurityService.secureLog('Session restoration failed', error: e);
    } finally {
      _setLoading(false);
    }
  }

  /// Login with email and password
  /// 
  /// Authenticates the user with the backend API and stores the token
  /// and user data locally. Sets authentication state on success.
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final loginResponse = await _authRepository.login(email, password);
      _currentUser = loginResponse.user;
      _isAuthenticated = true;
      // Start security session tracking
      _securityService?.startSession();
      SecurityService.secureLog('User logged in successfully');
      _setLoading(false);
      return true;
    } on AuthenticationException catch (e) {
      _setError(e.message);
      _isAuthenticated = false;
      _currentUser = null;
      _setLoading(false);
      SecurityService.secureLog('Authentication error: ${e.message}');
      return false;
    } on NetworkException catch (e) {
      _setError(e.message);
      _isAuthenticated = false;
      _currentUser = null;
      _setLoading(false);
      SecurityService.secureLog('Network error: ${e.message}');
      return false;
    } catch (e) {
      final errorMessage = 'Login failed: ${e.toString()}';
      _setError(errorMessage);
      _isAuthenticated = false;
      _currentUser = null;
      _setLoading(false);
      SecurityService.secureLog('Login error: $errorMessage');
      return false;
    }
  }

  /// Logout and clear session
  /// 
  /// Calls the logout endpoint, clears stored credentials, and resets
  /// authentication state. Always succeeds locally even if API call fails.
  Future<void> logout() async {
    _setLoading(true);
    _clearError();

    try {
      await _authRepository.logout();
    } catch (e) {
      // Continue with logout even if API call fails
      SecurityService.secureLog('Logout API call failed', error: e);
    } finally {
      _currentUser = null;
      _isAuthenticated = false;
      // End security session tracking
      _securityService?.endSession();
      SecurityService.secureLog('User logged out');
      _setLoading(false);
    }
  }

  /// Check authentication status
  /// 
  /// Verifies if the user is currently authenticated by checking
  /// stored credentials.
  Future<bool> checkAuthStatus() async {
    try {
      return await _authRepository.isAuthenticated();
    } catch (e) {
      return false;
    }
  }

  /// Refresh authentication token
  /// 
  /// Attempts to refresh the authentication token using the refresh token.
  /// If successful, updates the stored token. If failed, logs out the user.
  Future<bool> refreshToken() async {
    try {
      final newToken = await _authRepository.refreshToken();
      if (newToken != null) {
        return true;
      } else {
        // Refresh failed, logout user
        SecurityService.secureLog('Token refresh failed - logging out user');
        await logout();
        return false;
      }
    } catch (e) {
      // Refresh failed, logout user
      SecurityService.secureLog('Token refresh error - logging out user', error: e);
      await logout();
      return false;
    }
  }

  /// Get current user from backend
  /// 
  /// Fetches the latest user data from the backend and updates
  /// the stored user data. Useful for refreshing user information.
  Future<void> refreshUser() async {
    if (!_isAuthenticated) return;

    try {
      _currentUser = await _authRepository.getCurrentUser();
      notifyListeners();
    } catch (e) {
      _setError('Failed to refresh user data');
    }
  }

  /// Handle token expiration
  /// 
  /// Called when a token expiration is detected. Attempts to refresh
  /// the token, and if that fails, logs out the user.
  Future<void> handleTokenExpiration() async {
    final refreshed = await refreshToken();
    if (!refreshed) {
      _setError('Session expired. Please login again.');
    }
  }

  // Private helper methods

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
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _clearError();
  }
}
