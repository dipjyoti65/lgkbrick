import '../models/user.dart';
import '../models/user_request.dart';
import '../models/api_response.dart';
import '../models/role.dart';
import '../models/department.dart';
import '../services/api_service.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/exceptions/app_exception.dart';

/// Repository for user management operations
class UserRepository {
  final ApiService _apiService;

  UserRepository({required ApiService apiService}) : _apiService = apiService;

  /// Get list of users with optional filtering
  Future<List<User>> getUsers({
    String? search,
    int? roleId,
    int? departmentId,
    String? status,
    int? page,
    int? perPage,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null) queryParams['search'] = search;
      if (roleId != null) queryParams['role_id'] = roleId;
      if (departmentId != null) queryParams['department_id'] = departmentId;
      if (status != null) queryParams['status'] = status;
      if (page != null) queryParams['page'] = page;
      if (perPage != null) queryParams['per_page'] = perPage;

      final response = await _apiService.get(
        ApiEndpoints.users,
        queryParameters: queryParams,
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw AppException(apiResponse.message ?? 'Failed to fetch users');
      }

      // Handle both paginated and non-paginated responses
      final data = apiResponse.data!;
      List<dynamic> usersJson;

      if (data.containsKey('users') && data['users'] is List) {
        // Standard response format: { data: { users: [...] } }
        usersJson = data['users'] as List<dynamic>;
      } else if (data.containsKey('data') && data['data'] is List) {
        // Paginated response format: { data: { data: [...] } }
        usersJson = data['data'] as List<dynamic>;
      } else if (data is List) {
        // Direct list response
        usersJson = data as List<dynamic>;
      } else {
        throw AppException('Unexpected response format: ${data.keys}');
      }

      return usersJson
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to fetch users: ${e.toString()}');
    }
  }

  /// Get user by ID
  Future<User> getUserById(int id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.userById(id));

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw AppException(apiResponse.message ?? 'Failed to fetch user');
      }

      // The API returns { "data": { "user": { ... } } }
      final userData = apiResponse.data!['user'] as Map<String, dynamic>;
      return User.fromJson(userData);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to fetch user: ${e.toString()}');
    }
  }

  /// Create new user
  Future<User> createUser(CreateUserRequest request) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.users,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw ValidationException(
          apiResponse.message ?? 'Failed to create user',
          apiResponse.errors,
        );
      }

      // The API returns { "data": { "user": { ... } } }
      final userData = apiResponse.data!['user'] as Map<String, dynamic>;
      return User.fromJson(userData);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to create user: ${e.toString()}');
    }
  }

  /// Update existing user
  Future<User> updateUser(int id, UpdateUserRequest request) async {
    try {
      final response = await _apiService.put(
        ApiEndpoints.userById(id),
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw ValidationException(
          apiResponse.message ?? 'Failed to update user',
          apiResponse.errors,
        );
      }

      // The API returns { "data": { "user": { ... } } }
      final userData = apiResponse.data!['user'] as Map<String, dynamic>;
      return User.fromJson(userData);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to update user: ${e.toString()}');
    }
  }

  /// Delete user
  Future<void> deleteUser(int id) async {
    try {
      final response = await _apiService.delete(ApiEndpoints.userById(id));

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess) {
        throw AppException(apiResponse.message ?? 'Failed to delete user');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to delete user: ${e.toString()}');
    }
  }

  /// Get form data (roles and departments) for user creation/editing
  Future<UserFormData> getUserFormData() async {
    try {
      final response = await _apiService.get(ApiEndpoints.usersFormData);

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw AppException(
          apiResponse.message ?? 'Failed to fetch form data',
        );
      }

      final data = apiResponse.data!;
      final rolesJson = data['roles'] as List<dynamic>;
      final departmentsJson = data['departments'] as List<dynamic>;

      final roles = rolesJson
          .map((json) => Role.fromJson(json as Map<String, dynamic>))
          .toList();

      final departments = departmentsJson
          .map((json) => Department.fromJson(json as Map<String, dynamic>))
          .toList();

      return UserFormData(roles: roles, departments: departments);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to fetch form data: ${e.toString()}');
    }
  }

  /// Update user status
  Future<User> updateUserStatus(int id, String status) async {
    try {
      final response = await _apiService.patch(
        ApiEndpoints.userById(id),
        data: {'status': status},
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw AppException(
          apiResponse.message ?? 'Failed to update user status',
        );
      }

      // The API returns { "data": { "user": { ... } } }
      final userData = apiResponse.data!['user'] as Map<String, dynamic>;
      return User.fromJson(userData);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to update user status: ${e.toString()}');
    }
  }
}

/// Data class for user form data
class UserFormData {
  final List<Role> roles;
  final List<Department> departments;

  UserFormData({
    required this.roles,
    required this.departments,
  });
}
