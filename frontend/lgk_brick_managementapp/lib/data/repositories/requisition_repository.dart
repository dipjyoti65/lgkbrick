import '../models/requisition.dart';
import '../models/requisition_request.dart';
import '../models/api_response.dart';
import '../services/api_service.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/exceptions/app_exception.dart';

/// Repository for requisition management operations
class RequisitionRepository {
  final ApiService _apiService;

  RequisitionRepository({required ApiService apiService})
      : _apiService = apiService;

  /// Get list of requisitions with optional filtering
  Future<List<Requisition>> getRequisitions({
    String? search,
    String? status,
    int? userId,
    int? brickTypeId,
    String? startDate,
    String? endDate,
    int? page,
    int? perPage,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null) queryParams['search'] = search;
      if (status != null) queryParams['status'] = status;
      if (userId != null) queryParams['user_id'] = userId;
      if (brickTypeId != null) queryParams['brick_type_id'] = brickTypeId;
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;
      if (page != null) queryParams['page'] = page;
      if (perPage != null) queryParams['per_page'] = perPage;

      final response = await _apiService.get(
        ApiEndpoints.requisitions,
        queryParameters: queryParams,
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw AppException(
          apiResponse.message ?? 'Failed to fetch requisitions',
        );
      }

      // Handle both paginated and non-paginated responses
      final data = apiResponse.data!;
      List<dynamic> requisitionsJson;

      if (data.containsKey('data') && data['data'] is List) {
        // Paginated response
        requisitionsJson = data['data'] as List<dynamic>;
      } else if (data is List) {
        // Direct list response
        requisitionsJson = data as List<dynamic>;
      } else {
        throw AppException('Unexpected response format');
      }

      return requisitionsJson
          .map((json) => Requisition.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to fetch requisitions: ${e.toString()}');
    }
  }

  /// Get pending requisitions (for logistics)
  Future<List<Requisition>> getPendingRequisitions() async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.pendingRequisitions,
      );

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List<dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw AppException(
          apiResponse.message ?? 'Failed to fetch pending requisitions',
        );
      }

      return apiResponse.data!
          .map((json) => Requisition.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException(
        'Failed to fetch pending requisitions: ${e.toString()}',
      );
    }
  }

  /// Get requisition by ID
  Future<Requisition> getRequisitionById(int id) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.requisitionById(id),
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw AppException(
          apiResponse.message ?? 'Failed to fetch requisition',
        );
      }

      return Requisition.fromJson(apiResponse.data!);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to fetch requisition: ${e.toString()}');
    }
  }

  /// Create new requisition
  Future<Requisition> createRequisition(
    RequisitionRequest request,
  ) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.requisitions,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw ValidationException(
          apiResponse.message ?? 'Failed to create requisition',
          apiResponse.errors,
        );
      }

      return Requisition.fromJson(apiResponse.data!);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to create requisition: ${e.toString()}');
    }
  }

  /// Update requisition (only if not submitted)
  Future<Requisition> updateRequisition(
    int id,
    RequisitionRequest request,
  ) async {
    try {
      final response = await _apiService.put(
        ApiEndpoints.requisitionById(id),
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw ValidationException(
          apiResponse.message ?? 'Failed to update requisition',
          apiResponse.errors,
        );
      }

      return Requisition.fromJson(apiResponse.data!);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to update requisition: ${e.toString()}');
    }
  }

  /// Delete requisition
  Future<void> deleteRequisition(int id) async {
    try {
      final response = await _apiService.delete(
        ApiEndpoints.requisitionById(id),
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess) {
        throw AppException(
          apiResponse.message ?? 'Failed to delete requisition',
        );
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to delete requisition: ${e.toString()}');
    }
  }

  /// Calculate total amount for requisition
  /// This is a client-side helper that should match backend calculation
  double calculateTotalAmount(String quantity, String pricePerUnit) {
    try {
      final qty = double.parse(quantity);
      final price = double.parse(pricePerUnit);
      return qty * price;
    } catch (e) {
      return 0.0;
    }
  }

  /// Validate price against current brick type price
  /// This ensures frontend calculations match backend expectations
  Future<bool> validatePrice(int brickTypeId, String pricePerUnit) async {
    try {
      // This would typically call a backend endpoint to validate
      // For now, we'll assume validation happens on submission
      return true;
    } catch (e) {
      return false;
    }
  }
}
