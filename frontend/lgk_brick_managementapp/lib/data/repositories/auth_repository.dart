import '../models/auth_models.dart';
import '../models/user.dart';
import '../models/api_response.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/exceptions/app_exception.dart';

/// Repository for authentication operations
class AuthRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthRepository({
    required ApiService apiService,
    required StorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService;

  /// Login with email and password
  Future<LoginResponse> login(String email, String password) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _apiService.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw AuthenticationException(
          apiResponse.message ?? 'Login failed',
        );
      }

      final loginResponse = LoginResponse.fromJson(apiResponse.data!);

      // Store token and user data
      await _storageService.saveToken(loginResponse.token);
      await _storageService.saveUser(loginResponse.user);

      // Set token in API service for subsequent requests
      _apiService.setAuthToken(loginResponse.token);

      return loginResponse;
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AuthenticationException('Login failed: ${e.toString()}');
    }
  }

  /// Logout and clear stored credentials
  Future<void> logout() async {
    try {
      // Call logout endpoint if token exists
      final hasToken = await _storageService.hasToken();
      if (hasToken) {
        try {
          await _apiService.post(ApiEndpoints.logout);
        } catch (e) {
          // Continue with local logout even if API call fails
        }
      }

      // Clear stored data
      await _storageService.clearAuthData();
      _apiService.clearAuthToken();
    } catch (e) {
      throw StorageException('Logout failed: ${e.toString()}');
    }
  }

  /// Get current authenticated user
  Future<User> getCurrentUser() async {
    try {
      final response = await _apiService.get(ApiEndpoints.currentUser);

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw AuthenticationException('Failed to get current user');
      }

      final user = User.fromJson(apiResponse.data!);

      // Update stored user data
      await _storageService.saveUser(user);

      return user;
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AuthenticationException(
        'Failed to get current user: ${e.toString()}',
      );
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      final hasToken = await _storageService.hasToken();
      final hasUser = await _storageService.hasUser();
      return hasToken && hasUser;
    } catch (e) {
      return false;
    }
  }

  /// Get stored user data
  Future<User?> getStoredUser() async {
    try {
      return await _storageService.getUser();
    } catch (e) {
      return null;
    }
  }

  /// Get stored token
  Future<String?> getStoredToken() async {
    try {
      return await _storageService.getToken();
    } catch (e) {
      return null;
    }
  }

  /// Restore session from stored credentials
  Future<bool> restoreSession() async {
    try {
      final token = await _storageService.getToken();
      final user = await _storageService.getUser();

      if (token == null || user == null) {
        return false;
      }

      // Set token in API service
      _apiService.setAuthToken(token);

      // For now, just trust the stored credentials without API verification
      // This prevents hanging when backend is not available
      // TODO: Add background token verification
      return true;
      
      // Uncomment below for strict token verification (requires backend)
      /*
      // Verify token is still valid by fetching current user
      try {
        await getCurrentUser();
        return true;
      } catch (e) {
        // Token is invalid, clear stored data
        await _storageService.clearAuthData();
        _apiService.clearAuthToken();
        return false;
      }
      */
    } catch (e) {
      return false;
    }
  }

  /// Refresh authentication token
  Future<String?> refreshToken() async {
    try {
      // Note: This assumes the backend has a refresh token endpoint
      // Adjust based on actual backend implementation
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null) {
        return null;
      }

      final response = await _apiService.post(
        '/refresh-token',
        data: {'refresh_token': refreshToken},
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        return null;
      }

      final newToken = apiResponse.data!['token'] as String?;
      if (newToken != null) {
        await _storageService.saveToken(newToken);
        _apiService.setAuthToken(newToken);
      }

      return newToken;
    } catch (e) {
      return null;
    }
  }
}
