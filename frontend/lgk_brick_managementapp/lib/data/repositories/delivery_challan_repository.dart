import '../models/delivery_challan.dart';
import '../models/delivery_challan_request.dart';
import '../models/api_response.dart';
import '../services/api_service.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/exceptions/app_exception.dart';

/// Repository for delivery challan management operations
class DeliveryChallanRepository {
  final ApiService _apiService;

  DeliveryChallanRepository({required ApiService apiService})
      : _apiService = apiService;

  /// Get list of all delivery challans with optional filtering
  Future<List<DeliveryChallan>> getDeliveryChallans({
    String? deliveryStatus,
    String? date,
    int? page,
    int? perPage,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (deliveryStatus != null) queryParams['delivery_status'] = deliveryStatus;
      if (date != null) queryParams['date'] = date;
      if (page != null) queryParams['page'] = page;
      if (perPage != null) queryParams['per_page'] = perPage;

      final response = await _apiService.get(
        ApiEndpoints.deliveryChallans,
        queryParameters: queryParams,
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw AppException(
          apiResponse.message ?? 'Failed to fetch delivery challans',
        );
      }

      // Handle both paginated and non-paginated responses
      final data = apiResponse.data!;
      List<dynamic> challansJson;

      if (data.containsKey('data') && data['data'] is List) {
        // Paginated response
        challansJson = data['data'] as List<dynamic>;
      } else if (data is List) {
        // Direct list response
        challansJson = data as List<dynamic>;
      } else {
        throw AppException('Unexpected response format');
      }

      return challansJson
          .map((json) => DeliveryChallan.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to fetch delivery challans: ${e.toString()}');
    }
  }

  /// Get delivery challan by ID
  Future<DeliveryChallan> getDeliveryChallanById(int id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.deliveryChallanById(id));

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw AppException(
          apiResponse.message ?? 'Failed to fetch delivery challan',
        );
      }

      return DeliveryChallan.fromJson(apiResponse.data!);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to fetch delivery challan: ${e.toString()}');
    }
  }

  /// Create new delivery challan
  Future<DeliveryChallan> createDeliveryChallan(DeliveryChallanRequest request) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.deliveryChallans,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw ValidationException(
          apiResponse.message ?? 'Failed to create delivery challan',
          apiResponse.errors,
        );
      }

      return DeliveryChallan.fromJson(apiResponse.data!);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to create delivery challan: ${e.toString()}');
    }
  }

  /// Update delivery challan status
  Future<DeliveryChallan> updateDeliveryStatus(
    int id,
    String deliveryStatus, {
    String? remarks,
  }) async {
    try {
      final data = <String, dynamic>{
        'delivery_status': deliveryStatus,
      };
      if (remarks != null) {
        data['remarks'] = remarks;
      }

      final response = await _apiService.patch(
        ApiEndpoints.deliveryChallanStatus(id),
        data: data,
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw AppException(
          apiResponse.message ?? 'Failed to update delivery status',
        );
      }

      return DeliveryChallan.fromJson(apiResponse.data!);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException(
        'Failed to update delivery status: ${e.toString()}',
      );
    }
  }

  /// Get pending orders for challan creation
  Future<List<Map<String, dynamic>>> getPendingOrders() async {
    try {
      final response = await _apiService.get(ApiEndpoints.pendingOrders);

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List<dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw AppException(
          apiResponse.message ?? 'Failed to fetch pending orders',
        );
      }

      return apiResponse.data!
          .map((json) => json as Map<String, dynamic>)
          .toList();
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to fetch pending orders: ${e.toString()}');
    }
  }

  /// Generate printable challan
  Future<Map<String, dynamic>> printChallan(int id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.deliveryChallanPrint(id));

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw AppException(
          apiResponse.message ?? 'Failed to generate printable challan',
        );
      }

      return apiResponse.data!;
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to generate printable challan: ${e.toString()}');
    }
  }
}