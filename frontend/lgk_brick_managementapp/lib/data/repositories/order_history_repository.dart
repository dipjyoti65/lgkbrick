import '../models/order_history.dart';
import '../models/api_response.dart';
import '../services/api_service.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/exceptions/app_exception.dart';

/// Repository for order history operations
class OrderHistoryRepository {
  final ApiService _apiService;

  OrderHistoryRepository({required ApiService apiService})
      : _apiService = apiService;

  /// Get order history with filtering and pagination
  Future<List<OrderHistory>> getOrderHistory({
    String? paymentStatus,
    String? orderStatus,
    String? fromDate,
    String? toDate,
    String? search,
    int? page,
    int? perPage,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (paymentStatus != null) queryParams['payment_status'] = paymentStatus;
      if (orderStatus != null) queryParams['order_status'] = orderStatus;
      if (fromDate != null) queryParams['from_date'] = fromDate;
      if (toDate != null) queryParams['to_date'] = toDate;
      if (search != null) queryParams['search'] = search;
      if (page != null) queryParams['page'] = page;
      if (perPage != null) queryParams['per_page'] = perPage;

      final response = await _apiService.get(
        ApiEndpoints.orderHistory,
        queryParameters: queryParams,
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw AppException(
          apiResponse.message ?? 'Failed to fetch order history',
        );
      }

      final data = apiResponse.data!;
      if (!data.containsKey('orders') || data['orders'] is! List) {
        throw AppException('Invalid response format: missing orders array');
      }

      final ordersJson = data['orders'] as List<dynamic>;
      return ordersJson
          .map((json) => OrderHistory.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to fetch order history: ${e.toString()}');
    }
  }

  /// Get detailed order information
  Future<OrderDetails> getOrderDetails(int id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.orderHistoryById(id));

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw AppException(
          apiResponse.message ?? 'Failed to fetch order details',
        );
      }

      final orderData = apiResponse.data!['order'] as Map<String, dynamic>;
      return OrderDetails.fromJson(orderData);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to fetch order details: ${e.toString()}');
    }
  }

  /// Get order statistics
  Future<OrderStatistics> getOrderStatistics({
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (fromDate != null) queryParams['from_date'] = fromDate;
      if (toDate != null) queryParams['to_date'] = toDate;

      final response = await _apiService.get(
        ApiEndpoints.orderHistoryStatistics,
        queryParameters: queryParams,
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw AppException(
          apiResponse.message ?? 'Failed to fetch order statistics',
        );
      }

      final statisticsData = apiResponse.data!['statistics'] as Map<String, dynamic>;
      return OrderStatistics.fromJson(statisticsData);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to fetch order statistics: ${e.toString()}');
    }
  }

  /// Generate PDF for order
  Future<Map<String, dynamic>> generateOrderPdf(int id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.orderHistoryPdf(id));

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw AppException(
          apiResponse.message ?? 'Failed to generate PDF',
        );
      }

      return apiResponse.data!;
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to generate PDF: ${e.toString()}');
    }
  }

  /// Export orders to Excel
  Future<Map<String, dynamic>> exportOrdersToExcel({
    String? paymentStatus,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (paymentStatus != null) queryParams['payment_status'] = paymentStatus;
      if (fromDate != null) queryParams['from_date'] = fromDate;
      if (toDate != null) queryParams['to_date'] = toDate;

      final response = await _apiService.get(
        ApiEndpoints.orderHistoryExportExcel,
        queryParameters: queryParams,
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw AppException(
          apiResponse.message ?? 'Failed to export orders',
        );
      }

      return apiResponse.data!;
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to export orders: ${e.toString()}');
    }
  }
}