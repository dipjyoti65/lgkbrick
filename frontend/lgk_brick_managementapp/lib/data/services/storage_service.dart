import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/exceptions/app_exception.dart';
import '../models/user.dart';

/// Service for local data persistence with secure storage for sensitive data
class StorageService {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  // Storage keys
  static const String _keyAuthToken = 'auth_token';
  static const String _keyUser = 'user_data';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyLastSync = 'last_sync';

  StorageService({
    FlutterSecureStorage? secureStorage,
    required SharedPreferences prefs,
  })  : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
            ),
        _prefs = prefs;

  // ==================== Authentication Token Management ====================

  /// Save authentication token securely
  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: _keyAuthToken, value: token);
    } catch (e) {
      throw StorageException('Failed to save authentication token: $e');
    }
  }

  /// Get authentication token
  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: _keyAuthToken);
    } catch (e) {
      throw StorageException('Failed to retrieve authentication token: $e');
    }
  }

  /// Delete authentication token
  Future<void> deleteToken() async {
    try {
      await _secureStorage.delete(key: _keyAuthToken);
    } catch (e) {
      throw StorageException('Failed to delete authentication token: $e');
    }
  }

  /// Check if authentication token exists
  Future<bool> hasToken() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // ==================== Refresh Token Management ====================

  /// Save refresh token securely
  Future<void> saveRefreshToken(String token) async {
    try {
      await _secureStorage.write(key: _keyRefreshToken, value: token);
    } catch (e) {
      throw StorageException('Failed to save refresh token: $e');
    }
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: _keyRefreshToken);
    } catch (e) {
      throw StorageException('Failed to retrieve refresh token: $e');
    }
  }

  /// Delete refresh token
  Future<void> deleteRefreshToken() async {
    try {
      await _secureStorage.delete(key: _keyRefreshToken);
    } catch (e) {
      throw StorageException('Failed to delete refresh token: $e');
    }
  }

  // ==================== User Data Management ====================

  /// Save user data
  Future<void> saveUser(User user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await _prefs.setString(_keyUser, userJson);
    } catch (e) {
      throw StorageException('Failed to save user data: $e');
    }
  }

  /// Get user data
  Future<User?> getUser() async {
    try {
      final userJson = _prefs.getString(_keyUser);
      if (userJson == null) return null;
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromJson(userMap);
    } catch (e) {
      throw StorageException('Failed to retrieve user data: $e');
    }
  }

  /// Delete user data
  Future<void> deleteUser() async {
    try {
      await _prefs.remove(_keyUser);
    } catch (e) {
      throw StorageException('Failed to delete user data: $e');
    }
  }

  /// Check if user data exists
  Future<bool> hasUser() async {
    try {
      final user = await getUser();
      return user != null;
    } catch (e) {
      return false;
    }
  }

  // ==================== Cache Management ====================

  /// Save data to cache with a key
  Future<void> cacheData(String key, dynamic data) async {
    try {
      final jsonData = jsonEncode(data);
      await _prefs.setString(key, jsonData);
    } catch (e) {
      throw CacheException('Failed to cache data: $e');
    }
  }

  /// Get cached data by key
  Future<dynamic> getCachedData(String key) async {
    try {
      final jsonData = _prefs.getString(key);
      if (jsonData == null) return null;
      return jsonDecode(jsonData);
    } catch (e) {
      throw CacheException('Failed to retrieve cached data: $e');
    }
  }

  /// Delete cached data by key
  Future<void> deleteCachedData(String key) async {
    try {
      await _prefs.remove(key);
    } catch (e) {
      throw CacheException('Failed to delete cached data: $e');
    }
  }

  /// Check if cached data exists
  bool hasCachedData(String key) {
    return _prefs.containsKey(key);
  }

  /// Clear all cached data (except auth and user data)
  Future<void> clearCache() async {
    try {
      final keys = _prefs.getKeys();
      for (final key in keys) {
        if (key != _keyUser && key != _keyLastSync) {
          await _prefs.remove(key);
        }
      }
    } catch (e) {
      throw CacheException('Failed to clear cache: $e');
    }
  }

  // ==================== Sync Management ====================

  /// Save last sync timestamp
  Future<void> saveLastSync(DateTime timestamp) async {
    try {
      await _prefs.setString(_keyLastSync, timestamp.toIso8601String());
    } catch (e) {
      throw StorageException('Failed to save last sync timestamp: $e');
    }
  }

  /// Get last sync timestamp
  Future<DateTime?> getLastSync() async {
    try {
      final timestampStr = _prefs.getString(_keyLastSync);
      if (timestampStr == null) return null;
      return DateTime.parse(timestampStr);
    } catch (e) {
      return null;
    }
  }

  // ==================== Complete Data Clearing ====================

  /// Clear all stored data (logout)
  Future<void> clearAll() async {
    try {
      // Clear secure storage
      await _secureStorage.deleteAll();
      // Clear shared preferences
      await _prefs.clear();
    } catch (e) {
      throw StorageException('Failed to clear all data: $e');
    }
  }

  /// Clear only authentication data
  Future<void> clearAuthData() async {
    try {
      await deleteToken();
      await deleteRefreshToken();
      await deleteUser();
    } catch (e) {
      throw StorageException('Failed to clear authentication data: $e');
    }
  }

  // ==================== Generic Storage Methods ====================

  /// Save string value
  Future<void> saveString(String key, String value) async {
    try {
      await _prefs.setString(key, value);
    } catch (e) {
      throw StorageException('Failed to save string: $e');
    }
  }

  /// Get string value
  String? getString(String key) {
    return _prefs.getString(key);
  }

  /// Save boolean value
  Future<void> saveBool(String key, bool value) async {
    try {
      await _prefs.setBool(key, value);
    } catch (e) {
      throw StorageException('Failed to save boolean: $e');
    }
  }

  /// Get boolean value
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  /// Save integer value
  Future<void> saveInt(String key, int value) async {
    try {
      await _prefs.setInt(key, value);
    } catch (e) {
      throw StorageException('Failed to save integer: $e');
    }
  }

  /// Get integer value
  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  /// Save double value
  Future<void> saveDouble(String key, double value) async {
    try {
      await _prefs.setDouble(key, value);
    } catch (e) {
      throw StorageException('Failed to save double: $e');
    }
  }

  /// Get double value
  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  /// Remove value by key
  Future<void> remove(String key) async {
    try {
      await _prefs.remove(key);
    } catch (e) {
      throw StorageException('Failed to remove value: $e');
    }
  }

  /// Check if key exists
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }
}
