import '../models/brick_type.dart';
import '../models/brick_type_request.dart';
import '../models/api_response.dart';
import '../services/api_service.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/exceptions/app_exception.dart';

/// Repository for brick type management operations
class BrickTypeRepository {
  final ApiService _apiService;

  BrickTypeRepository({required ApiService apiService})
      : _apiService = apiService;

  /// Get list of all brick types with optional filtering
  Future<List<BrickType>> getBrickTypes({
    String? search,
    String? status,
    String? category,
    int? page,
    int? perPage,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null) queryParams['search'] = search;
      if (status != null) queryParams['status'] = status;
      if (category != null) queryParams['category'] = category;
      if (page != null) queryParams['page'] = page;
      if (perPage != null) queryParams['per_page'] = perPage;

      final response = await _apiService.get(
        ApiEndpoints.brickTypes,
        queryParameters: queryParams,
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw AppException(
          apiResponse.message ?? 'Failed to fetch brick types',
        );
      }

      // Handle both paginated and non-paginated responses
      final data = apiResponse.data!;
      List<dynamic> brickTypesJson;

      if (data.containsKey('brick_types') && data['brick_types'] is List) {
        // Standard response format: { data: { brick_types: [...] } }
        brickTypesJson = data['brick_types'] as List<dynamic>;
      } else if (data.containsKey('data') && data['data'] is List) {
        // Paginated response format: { data: { data: [...] } }
        brickTypesJson = data['data'] as List<dynamic>;
      } else if (data is List) {
        // Direct list response
        brickTypesJson = data as List<dynamic>;
      } else {
        throw AppException('Unexpected response format: ${data.keys}');
      }

      return brickTypesJson
          .map((json) => BrickType.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to fetch brick types: ${e.toString()}');
    }
  }

  /// Get list of active brick types only
  Future<List<BrickType>> getActiveBrickTypes() async {
    try {
      final response = await _apiService.get(ApiEndpoints.activeBrickTypes);

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw AppException(
          apiResponse.message ?? 'Failed to fetch active brick types',
        );
      }

      // Extract brick_types array from the nested data structure
      final data = apiResponse.data!;
      if (!data.containsKey('brick_types') || data['brick_types'] is! List) {
        throw AppException('Invalid response format: missing brick_types array');
      }

      final brickTypesJson = data['brick_types'] as List<dynamic>;
      return brickTypesJson
          .map((json) => BrickType.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to fetch active brick types: ${e.toString()}');
    }
  }

  /// Get brick type by ID
  Future<BrickType> getBrickTypeById(int id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.brickTypeById(id));

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw AppException(
          apiResponse.message ?? 'Failed to fetch brick type',
        );
      }

      // The API returns { "data": { "brick_type": { ... } } }
      final brickTypeData = apiResponse.data!['brick_type'] as Map<String, dynamic>;
      return BrickType.fromJson(brickTypeData);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to fetch brick type: ${e.toString()}');
    }
  }

  /// Create new brick type
  Future<BrickType> createBrickType(BrickTypeRequest request) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.brickTypes,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw ValidationException(
          apiResponse.message ?? 'Failed to create brick type',
          apiResponse.errors,
        );
      }

      // The API returns { "data": { "brick_type": { ... } } }
      final brickTypeData = apiResponse.data!['brick_type'] as Map<String, dynamic>;
      return BrickType.fromJson(brickTypeData);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to create brick type: ${e.toString()}');
    }
  }

  /// Update existing brick type
  Future<BrickType> updateBrickType(
    int id,
    BrickTypeRequest request,
  ) async {
    try {
      final response = await _apiService.put(
        ApiEndpoints.brickTypeById(id),
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw ValidationException(
          apiResponse.message ?? 'Failed to update brick type',
          apiResponse.errors,
        );
      }

      // The API returns { "data": { "brick_type": { ... } } }
      final brickTypeData = apiResponse.data!['brick_type'] as Map<String, dynamic>;
      return BrickType.fromJson(brickTypeData);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to update brick type: ${e.toString()}');
    }
  }

  /// Update brick type status
  Future<BrickType> updateBrickTypeStatus(int id, String status) async {
    try {
      final response = await _apiService.patch(
        ApiEndpoints.brickTypeStatus(id),
        data: {'status': status},
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw AppException(
          apiResponse.message ?? 'Failed to update brick type status',
        );
      }

      // The API returns { "data": { "brick_type": { ... } } }
      final brickTypeData = apiResponse.data!['brick_type'] as Map<String, dynamic>;
      return BrickType.fromJson(brickTypeData);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException(
        'Failed to update brick type status: ${e.toString()}',
      );
    }
  }

  /// Update brick type price
  Future<BrickType> updateBrickTypePrice(int id, String newPrice) async {
    try {
      final response = await _apiService.patch(
        ApiEndpoints.brickTypePrice(id),
        data: {'current_price': newPrice},
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw ValidationException(
          apiResponse.message ?? 'Failed to update brick type price',
          apiResponse.errors,
        );
      }

      // The API returns { "data": { "brick_type": { ... } } }
      final brickTypeData = apiResponse.data!['brick_type'] as Map<String, dynamic>;
      return BrickType.fromJson(brickTypeData);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to update brick type price: ${e.toString()}');
    }
  }

  /// Delete brick type
  Future<void> deleteBrickType(int id) async {
    try {
      final response = await _apiService.delete(
        ApiEndpoints.brickTypeById(id),
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess) {
        throw AppException(
          apiResponse.message ?? 'Failed to delete brick type',
        );
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to delete brick type: ${e.toString()}');
    }
  }
}
