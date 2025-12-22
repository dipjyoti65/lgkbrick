import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lgk_brick_managementapp/data/services/storage_service.dart';
import 'package:lgk_brick_managementapp/data/models/user.dart';
import 'package:lgk_brick_managementapp/data/models/role.dart';
import 'package:lgk_brick_managementapp/data/models/department.dart';

// Mock implementation of FlutterSecureStorage for testing
class MockSecureStorage implements FlutterSecureStorage {
  final Map<String, String> _storage = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _storage[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _storage[key];
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _storage.remove(key);
  }

  @override
  Future<void> deleteAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _storage.clear();
  }

  @override
  Future<Map<String, String>> readAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return Map.from(_storage);
  }

  @override
  Future<bool> containsKey({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _storage.containsKey(key);
  }

  @override
  void registerListener({
    required String key,
    required void Function(String?) listener,
  }) {
    // Not implemented for mock
  }

  @override
  void unregisterListener({
    required String key,
    required void Function(String?) listener,
  }) {
    // Not implemented for mock
  }

  @override
  void unregisterAllListenersForKey({required String key}) {
    // Not implemented for mock
  }

  @override
  void unregisterAllListeners() {
    // Not implemented for mock
  }

  @override
  Future<bool?> isCupertinoProtectedDataAvailable() async {
    return true;
  }

  @override
  Stream<bool>? get onCupertinoProtectedDataAvailabilityChanged => null;

  @override
  AndroidOptions get aOptions => throw UnimplementedError();

  @override
  IOSOptions get iOptions => throw UnimplementedError();

  @override
  LinuxOptions get lOptions => throw UnimplementedError();

  @override
  MacOsOptions get mOptions => throw UnimplementedError();

  @override
  WebOptions get webOptions => throw UnimplementedError();

  @override
  WindowsOptions get wOptions => throw UnimplementedError();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late StorageService storageService;
  late SharedPreferences prefs;
  late MockSecureStorage secureStorage;

  setUp(() async {
    // Initialize SharedPreferences with empty values
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    
    // Create mock secure storage
    secureStorage = MockSecureStorage();
    
    // Create StorageService with mock secure storage
    storageService = StorageService(
      prefs: prefs,
      secureStorage: secureStorage,
    );
  });

  group('StorageService - Authentication Token Management', () {
    test('should save and retrieve authentication token', () async {
      const testToken = 'test_auth_token_12345';
      
      await storageService.saveToken(testToken);
      final retrievedToken = await storageService.getToken();
      
      expect(retrievedToken, equals(testToken));
    });

    test('should return null when no token exists', () async {
      final retrievedToken = await storageService.getToken();
      expect(retrievedToken, isNull);
    });

    test('should check if token exists', () async {
      expect(await storageService.hasToken(), isFalse);
      
      await storageService.saveToken('test_token');
      
      expect(await storageService.hasToken(), isTrue);
    });

    test('should delete authentication token', () async {
      await storageService.saveToken('test_token');
      expect(await storageService.hasToken(), isTrue);
      
      await storageService.deleteToken();
      
      expect(await storageService.hasToken(), isFalse);
    });

    test('should save and retrieve refresh token', () async {
      const testRefreshToken = 'test_refresh_token_67890';
      
      await storageService.saveRefreshToken(testRefreshToken);
      final retrievedToken = await storageService.getRefreshToken();
      
      expect(retrievedToken, equals(testRefreshToken));
    });

    test('should delete refresh token', () async {
      await storageService.saveRefreshToken('test_refresh_token');
      final token = await storageService.getRefreshToken();
      expect(token, isNotNull);
      
      await storageService.deleteRefreshToken();
      
      final deletedToken = await storageService.getRefreshToken();
      expect(deletedToken, isNull);
    });

    test('should clear all authentication data', () async {
      await storageService.saveToken('test_token');
      await storageService.saveRefreshToken('test_refresh_token');
      
      final testUser = User(
        id: 1,
        name: 'Test User',
        email: 'test@example.com',
        roleId: 1,
        departmentId: 1,
        role: Role(id: 1, name: 'Admin', permissions: []),
        department: Department(id: 1, name: 'IT'),
        status: 'active',
      );
      await storageService.saveUser(testUser);
      
      await storageService.clearAuthData();
      
      // Auth data should be cleared
      expect(await storageService.hasToken(), isFalse);
      expect(await storageService.getRefreshToken(), isNull);
      expect(await storageService.hasUser(), isFalse);
    });
  });

  group('StorageService - User Data Management', () {
    test('should save and retrieve user data', () async {
      final testUser = User(
        id: 1,
        name: 'Test User',
        email: 'test@example.com',
        roleId: 1,
        departmentId: 1,
        role: Role(id: 1, name: 'Admin', permissions: []),
        department: Department(id: 1, name: 'IT'),
        status: 'active',
      );
      
      await storageService.saveUser(testUser);
      final retrievedUser = await storageService.getUser();
      
      expect(retrievedUser, isNotNull);
      expect(retrievedUser!.id, equals(testUser.id));
      expect(retrievedUser.name, equals(testUser.name));
      expect(retrievedUser.email, equals(testUser.email));
      expect(retrievedUser.roleId, equals(testUser.roleId));
    });

    test('should return null when no user data exists', () async {
      final retrievedUser = await storageService.getUser();
      expect(retrievedUser, isNull);
    });

    test('should check if user data exists', () async {
      expect(await storageService.hasUser(), isFalse);
      
      final testUser = User(
        id: 1,
        name: 'Test User',
        email: 'test@example.com',
        roleId: 1,
        departmentId: 1,
        role: Role(id: 1, name: 'Admin', permissions: []),
        department: Department(id: 1, name: 'IT'),
        status: 'active',
      );
      
      await storageService.saveUser(testUser);
      
      expect(await storageService.hasUser(), isTrue);
    });

    test('should delete user data', () async {
      final testUser = User(
        id: 1,
        name: 'Test User',
        email: 'test@example.com',
        roleId: 1,
        departmentId: 1,
        role: Role(id: 1, name: 'Admin', permissions: []),
        department: Department(id: 1, name: 'IT'),
        status: 'active',
      );
      
      await storageService.saveUser(testUser);
      expect(await storageService.hasUser(), isTrue);
      
      await storageService.deleteUser();
      
      expect(await storageService.hasUser(), isFalse);
    });
  });

  group('StorageService - Cache Management', () {
    test('should cache and retrieve data', () async {
      const testKey = 'test_cache_key';
      final testData = {'name': 'Test', 'value': 123};
      
      await storageService.cacheData(testKey, testData);
      final retrievedData = await storageService.getCachedData(testKey);
      
      expect(retrievedData, isNotNull);
      expect(retrievedData['name'], equals('Test'));
      expect(retrievedData['value'], equals(123));
    });

    test('should return null for non-existent cached data', () async {
      final retrievedData = await storageService.getCachedData('non_existent_key');
      expect(retrievedData, isNull);
    });

    test('should check if cached data exists', () async {
      const testKey = 'test_cache_key';
      
      expect(storageService.hasCachedData(testKey), isFalse);
      
      await storageService.cacheData(testKey, {'test': 'data'});
      
      expect(storageService.hasCachedData(testKey), isTrue);
    });

    test('should delete cached data', () async {
      const testKey = 'test_cache_key';
      
      await storageService.cacheData(testKey, {'test': 'data'});
      expect(storageService.hasCachedData(testKey), isTrue);
      
      await storageService.deleteCachedData(testKey);
      
      expect(storageService.hasCachedData(testKey), isFalse);
    });

    test('should clear all cache except user and sync data', () async {
      await storageService.cacheData('cache1', {'data': 1});
      await storageService.cacheData('cache2', {'data': 2});
      await storageService.saveString('custom_key', 'custom_value');
      
      final testUser = User(
        id: 1,
        name: 'Test User',
        email: 'test@example.com',
        roleId: 1,
        departmentId: 1,
        role: Role(id: 1, name: 'Admin', permissions: []),
        department: Department(id: 1, name: 'IT'),
        status: 'active',
      );
      await storageService.saveUser(testUser);
      
      await storageService.clearCache();
      
      // Cache should be cleared
      expect(storageService.hasCachedData('cache1'), isFalse);
      expect(storageService.hasCachedData('cache2'), isFalse);
      expect(storageService.getString('custom_key'), isNull);
      
      // User data should be preserved
      expect(await storageService.hasUser(), isTrue);
    });
  });

  group('StorageService - Sync Management', () {
    test('should save and retrieve last sync timestamp', () async {
      final testTimestamp = DateTime(2024, 1, 15, 10, 30);
      
      await storageService.saveLastSync(testTimestamp);
      final retrievedTimestamp = await storageService.getLastSync();
      
      expect(retrievedTimestamp, isNotNull);
      expect(retrievedTimestamp!.year, equals(2024));
      expect(retrievedTimestamp.month, equals(1));
      expect(retrievedTimestamp.day, equals(15));
      expect(retrievedTimestamp.hour, equals(10));
      expect(retrievedTimestamp.minute, equals(30));
    });

    test('should return null when no sync timestamp exists', () async {
      final retrievedTimestamp = await storageService.getLastSync();
      expect(retrievedTimestamp, isNull);
    });
  });

  group('StorageService - Generic Storage Methods', () {
    test('should save and retrieve string values', () async {
      const testKey = 'test_string_key';
      const testValue = 'test_string_value';
      
      await storageService.saveString(testKey, testValue);
      final retrievedValue = storageService.getString(testKey);
      
      expect(retrievedValue, equals(testValue));
    });

    test('should return null for non-existent string key', () {
      final retrievedValue = storageService.getString('non_existent_key');
      expect(retrievedValue, isNull);
    });

    test('should save and retrieve boolean values', () async {
      const testKey = 'test_bool_key';
      const testValue = true;
      
      await storageService.saveBool(testKey, testValue);
      final retrievedValue = storageService.getBool(testKey);
      
      expect(retrievedValue, equals(testValue));
    });

    test('should save and retrieve integer values', () async {
      const testKey = 'test_int_key';
      const testValue = 42;
      
      await storageService.saveInt(testKey, testValue);
      final retrievedValue = storageService.getInt(testKey);
      
      expect(retrievedValue, equals(testValue));
    });

    test('should save and retrieve double values', () async {
      const testKey = 'test_double_key';
      const testValue = 3.14;
      
      await storageService.saveDouble(testKey, testValue);
      final retrievedValue = storageService.getDouble(testKey);
      
      expect(retrievedValue, equals(testValue));
    });

    test('should remove value by key', () async {
      const testKey = 'test_remove_key';
      
      await storageService.saveString(testKey, 'test_value');
      expect(storageService.containsKey(testKey), isTrue);
      
      await storageService.remove(testKey);
      
      expect(storageService.containsKey(testKey), isFalse);
    });

    test('should check if key exists', () async {
      const testKey = 'test_exists_key';
      
      expect(storageService.containsKey(testKey), isFalse);
      
      await storageService.saveString(testKey, 'test_value');
      
      expect(storageService.containsKey(testKey), isTrue);
    });
  });

  group('StorageService - Complete Data Clearing', () {
    test('should clear all stored data', () async {
      await storageService.saveString('test_key', 'test_value');
      await storageService.cacheData('cache_key', {'data': 'value'});
      
      final testUser = User(
        id: 1,
        name: 'Test User',
        email: 'test@example.com',
        roleId: 1,
        departmentId: 1,
        role: Role(id: 1, name: 'Admin', permissions: []),
        department: Department(id: 1, name: 'IT'),
        status: 'active',
      );
      await storageService.saveUser(testUser);
      
      await storageService.clearAll();
      
      // All data should be cleared
      expect(storageService.getString('test_key'), isNull);
      expect(storageService.hasCachedData('cache_key'), isFalse);
      expect(await storageService.hasUser(), isFalse);
    });
  });
}
