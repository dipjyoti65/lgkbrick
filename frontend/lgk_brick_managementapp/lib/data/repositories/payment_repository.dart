import '../models/payment.dart';
import '../models/payment_request.dart';
import '../models/delivery_challan.dart';
import '../models/api_response.dart';
import '../services/api_service.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/exceptions/app_exception.dart';

/// Repository for payment management operations
class PaymentRepository {
  final ApiService _apiService;

  PaymentRepository({required ApiService apiService})
      : _apiService = apiService;

  /// Get list of payments with optional filtering
  Future<List<Payment>> getPayments({
    String? search,
    String? status,
    String? startDate,
    String? endDate,
    int? page,
    int? perPage,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null) queryParams['search'] = search;
      if (status != null) queryParams['status'] = status;
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;
      if (page != null) queryParams['page'] = page;
      if (perPage != null) queryParams['per_page'] = perPage;

      final response = await _apiService.get(
        ApiEndpoints.payments,
        queryParameters: queryParams,
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw AppException(
          apiResponse.message ?? 'Failed to fetch payments',
        );
      }

      // Handle both paginated and non-paginated responses
      final data = apiResponse.data!;
      List<dynamic> paymentsJson;

      if (data.containsKey('data') && data['data'] is List) {
        // Paginated response
        paymentsJson = data['data'] as List<dynamic>;
      } else if (data is List) {
        // Direct list response
        paymentsJson = data as List<dynamic>;
      } else {
        throw AppException('Unexpected response format');
      }

      return paymentsJson
          .map((json) => Payment.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to fetch payments: ${e.toString()}');
    }
  }

  /// Get all challans with filtering and pagination
  Future<Map<String, dynamic>> getAllChallans({
    String status = 'all',
    String? startDate,
    String? endDate,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'status': status,
        'page': page,
        'per_page': perPage,
      };
      
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final response = await _apiService.get(
        ApiEndpoints.allChallans,
        queryParameters: queryParams,
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw AppException(
          apiResponse.message ?? 'Failed to fetch challans',
        );
      }

      final data = apiResponse.data!;
      List<dynamic> challansJson;

      if (data.containsKey('challans') && data['challans'] is List) {
        challansJson = data['challans'] as List<dynamic>;
      } else if (data.containsKey('data') && data['data'] is List) {
        challansJson = data['data'] as List<dynamic>;
      } else {
        throw AppException('Unexpected response format');
      }

      final challans = challansJson
          .map((json) => DeliveryChallan.fromJson(json as Map<String, dynamic>))
          .toList();

      return {
        'challans': challans,
        'currentPage': data['current_page'] ?? page,
        'totalPages': data['last_page'] ?? 1,
        'totalItems': data['total'] ?? challans.length,
      };
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to fetch challans: ${e.toString()}');
    }
  }

  /// Get pending challans (that need payment processing)
  Future<List<DeliveryChallan>> getDeliveredChallans() async {
    try {
      print('Making API call to: ${ApiEndpoints.pendingChallans}');
      
      final response = await _apiService.get(
        ApiEndpoints.pendingChallans,
      );

      print('API Response status: ${response.statusCode}');
      print('API Response data: ${response.data}');

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      print('Parsed API response success: ${apiResponse.isSuccess}');
      print('Parsed API response message: ${apiResponse.message}');

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw AppException(
          apiResponse.message ?? 'Failed to fetch pending challans',
        );
      }

      // Handle both paginated and non-paginated responses
      final data = apiResponse.data!;
      List<dynamic> challansJson;

      if (data.containsKey('challans') && data['challans'] is List) {
        // Response with challans key
        challansJson = data['challans'] as List<dynamic>;
      } else if (data.containsKey('data') && data['data'] is List) {
        // Paginated response
        challansJson = data['data'] as List<dynamic>;
      } else if (data is List) {
        // Direct list response
        challansJson = data as List<dynamic>;
      } else {
        throw AppException('Unexpected response format');
      }

      return challansJson
          .map((json) =>
              DeliveryChallan.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error in getDeliveredChallans: $e');
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to fetch pending challans: ${e.toString()}');
    }
  }

  /// Get payment by ID
  Future<Payment> getPaymentById(int id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.paymentById(id));

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw AppException(
          apiResponse.message ?? 'Failed to fetch payment',
        );
      }

      return Payment.fromJson(apiResponse.data!);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to fetch payment: ${e.toString()}');
    }
  }

  /// Create new payment
  Future<Payment> createPayment(PaymentRequest request) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.payments,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        // Log the detailed error for debugging
        print('Payment creation failed: ${apiResponse.message}');
        print('Validation errors: ${apiResponse.errors}');
        throw ValidationException(
          apiResponse.message ?? 'Failed to create payment',
          apiResponse.errors,
        );
      }

      return Payment.fromJson(apiResponse.data!);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to create payment: ${e.toString()}');
    }
  }

  /// Update payment
  Future<Payment> updatePayment(
    int id,
    PaymentRequest request,
  ) async {
    try {
      final response = await _apiService.put(
        ApiEndpoints.paymentById(id),
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw ValidationException(
          apiResponse.message ?? 'Failed to update payment',
          apiResponse.errors,
        );
      }

      return Payment.fromJson(apiResponse.data!);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to update payment: ${e.toString()}');
    }
  }

  /// Approve payment
  Future<Payment> approvePayment(int id) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.paymentApprove(id),
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw AppException(
          apiResponse.message ?? 'Failed to approve payment',
        );
      }

      return Payment.fromJson(apiResponse.data!);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to approve payment: ${e.toString()}');
    }
  }

  /// Delete payment
  Future<void> deletePayment(int id) async {
    try {
      final response = await _apiService.delete(
        ApiEndpoints.paymentById(id),
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess) {
        throw AppException(
          apiResponse.message ?? 'Failed to delete payment',
        );
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to delete payment: ${e.toString()}');
    }
  }

  /// Generate payment reports
  Future<PaymentReport> generateReports({
    String? startDate,
    String? endDate,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;
      if (status != null) queryParams['status'] = status;

      final response = await _apiService.get(
        ApiEndpoints.paymentReports,
        queryParameters: queryParams,
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw AppException(
          apiResponse.message ?? 'Failed to generate reports',
        );
      }

      return PaymentReport.fromJson(apiResponse.data!);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to generate reports: ${e.toString()}');
    }
  }

  /// Download payment report as PDF
  Future<void> downloadReportPdf(
    String savePath, {
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      await _apiService.downloadFile(
        ApiEndpoints.reportsRangePdf,
        savePath,
        queryParameters: queryParams,
      );
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to download report PDF: ${e.toString()}');
    }
  }

  /// Download payment report as Excel
  Future<void> downloadReportExcel(
    String savePath, {
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      await _apiService.downloadFile(
        ApiEndpoints.reportsRangeExcel,
        savePath,
        queryParameters: queryParams,
      );
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Failed to download report Excel: ${e.toString()}');
    }
  }
}

/// Payment report data class
class PaymentReport {
  final double totalAmount;
  final double totalReceived;
  final double totalPending;
  final int totalPayments;
  final int approvedPayments;
  final int pendingPayments;
  final List<Payment> payments;

  PaymentReport({
    required this.totalAmount,
    required this.totalReceived,
    required this.totalPending,
    required this.totalPayments,
    required this.approvedPayments,
    required this.pendingPayments,
    required this.payments,
  });

  factory PaymentReport.fromJson(Map<String, dynamic> json) {
    return PaymentReport(
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      totalReceived: (json['total_received'] as num?)?.toDouble() ?? 0.0,
      totalPending: (json['total_pending'] as num?)?.toDouble() ?? 0.0,
      totalPayments: json['total_payments'] as int? ?? 0,
      approvedPayments: json['approved_payments'] as int? ?? 0,
      pendingPayments: json['pending_payments'] as int? ?? 0,
      payments: (json['payments'] as List<dynamic>?)
              ?.map((e) => Payment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_amount': totalAmount,
      'total_received': totalReceived,
      'total_pending': totalPending,
      'total_payments': totalPayments,
      'approved_payments': approvedPayments,
      'pending_payments': pendingPayments,
      'payments': payments.map((e) => e.toJson()).toList(),
    };
  }
}
