import 'package:flutter/foundation.dart';
import '../../data/models/order_history.dart';
import '../../data/repositories/order_history_repository.dart';
import '../../core/exceptions/app_exception.dart';

/// Provider for order history management
class OrderHistoryProvider extends ChangeNotifier {
  final OrderHistoryRepository _orderHistoryRepository;

  // State
  List<OrderHistory> _orders = [];
  OrderDetails? _selectedOrder;
  OrderStatistics? _statistics;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  // Filters
  String? _paymentStatusFilter;
  String? _orderStatusFilter;
  String? _fromDate;
  String? _toDate;
  String? _searchQuery;

  OrderHistoryProvider({required OrderHistoryRepository orderHistoryRepository})
      : _orderHistoryRepository = orderHistoryRepository;

  // Getters
  List<OrderHistory> get orders => _orders;
  OrderDetails? get selectedOrder => _selectedOrder;
  OrderStatistics? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  String? get paymentStatusFilter => _paymentStatusFilter;
  String? get orderStatusFilter => _orderStatusFilter;
  String? get fromDate => _fromDate;
  String? get toDate => _toDate;
  String? get searchQuery => _searchQuery;

  /// Fetch order history with current filters
  Future<void> fetchOrderHistory() async {
    _setLoading(true);
    _clearError();
    _clearSuccessMessage();

    try {
      _orders = await _orderHistoryRepository.getOrderHistory(
        paymentStatus: _paymentStatusFilter,
        orderStatus: _orderStatusFilter,
        fromDate: _fromDate,
        toDate: _toDate,
        search: _searchQuery,
      );
      _setLoading(false);
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
    }
  }

  /// Fetch order details by ID
  Future<void> fetchOrderDetails(int id) async {
    _setLoading(true);
    _clearError();

    try {
      _selectedOrder = await _orderHistoryRepository.getOrderDetails(id);
      _setLoading(false);
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
    }
  }

  /// Fetch order statistics
  Future<void> fetchOrderStatistics() async {
    _clearError();

    try {
      _statistics = await _orderHistoryRepository.getOrderStatistics(
        fromDate: _fromDate,
        toDate: _toDate,
      );
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    }
  }

  /// Generate PDF for order
  Future<Map<String, dynamic>?> generateOrderPdf(int id) async {
    _setLoading(true);
    _clearError();
    _clearSuccessMessage();

    try {
      final result = await _orderHistoryRepository.generateOrderPdf(id);
      _setSuccessMessage('PDF generated successfully');
      _setLoading(false);
      return result;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return null;
    }
  }

  /// Export orders to Excel
  Future<Map<String, dynamic>?> exportOrdersToExcel() async {
    _setLoading(true);
    _clearError();
    _clearSuccessMessage();

    try {
      final result = await _orderHistoryRepository.exportOrdersToExcel(
        paymentStatus: _paymentStatusFilter,
        fromDate: _fromDate,
        toDate: _toDate,
      );
      _setSuccessMessage('Export data prepared successfully');
      _setLoading(false);
      return result;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return null;
    }
  }

  /// Set payment status filter
  void setPaymentStatusFilter(String? status) {
    _paymentStatusFilter = status;
    notifyListeners();
  }

  /// Set order status filter
  void setOrderStatusFilter(String? status) {
    _orderStatusFilter = status;
    notifyListeners();
  }

  /// Set date range filter
  void setDateRangeFilter(String? fromDate, String? toDate) {
    _fromDate = fromDate;
    _toDate = toDate;
    notifyListeners();
  }

  /// Set search query
  void setSearchQuery(String? query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _paymentStatusFilter = null;
    _orderStatusFilter = null;
    _fromDate = null;
    _toDate = null;
    _searchQuery = null;
    notifyListeners();
  }

  /// Apply filters and refresh data
  Future<void> applyFilters() async {
    await fetchOrderHistory();
    await fetchOrderStatistics();
  }

  /// Clear selected order
  void clearSelectedOrder() {
    _selectedOrder = null;
    notifyListeners();
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
  }

  void _setSuccessMessage(String message) {
    _successMessage = message;
    notifyListeners();
  }

  void _clearSuccessMessage() {
    _successMessage = null;
  }

  /// Clear error message
  void clearError() {
    _clearError();
    notifyListeners();
  }

  /// Clear success message
  void clearSuccessMessage() {
    _clearSuccessMessage();
    notifyListeners();
  }

  String _getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    } else {
      return error.toString();
    }
  }

  /// Get available payment status options
  List<Map<String, String>> get paymentStatusOptions => [
        {'value': '', 'label': 'All Payment Status'},
        {'value': 'pending', 'label': 'Pending'},
        {'value': 'partial', 'label': 'Partial'},
        {'value': 'paid', 'label': 'Paid'},
        {'value': 'approved', 'label': 'Approved'},
        {'value': 'overdue', 'label': 'Overdue'},
        {'value': 'no_payment', 'label': 'No Payment'},
      ];

  /// Get available order status options
  List<Map<String, String>> get orderStatusOptions => [
        {'value': '', 'label': 'All Order Status'},
        {'value': 'submitted', 'label': 'Submitted'},
        {'value': 'assigned', 'label': 'Assigned'},
        {'value': 'delivered', 'label': 'Delivered'},
        {'value': 'paid', 'label': 'Paid'},
        {'value': 'complete', 'label': 'Complete'},
      ];

  /// Check if any filters are applied
  bool get hasActiveFilters =>
      _paymentStatusFilter != null ||
      _orderStatusFilter != null ||
      _fromDate != null ||
      _toDate != null ||
      (_searchQuery != null && _searchQuery!.isNotEmpty);

  /// Get filter summary text
  String get filterSummary {
    final filters = <String>[];
    
    if (_paymentStatusFilter != null) {
      final option = paymentStatusOptions.firstWhere(
        (opt) => opt['value'] == _paymentStatusFilter,
        orElse: () => {'label': _paymentStatusFilter!},
      );
      filters.add('Payment: ${option['label']}');
    }
    
    if (_orderStatusFilter != null) {
      final option = orderStatusOptions.firstWhere(
        (opt) => opt['value'] == _orderStatusFilter,
        orElse: () => {'label': _orderStatusFilter!},
      );
      filters.add('Order: ${option['label']}');
    }
    
    if (_fromDate != null && _toDate != null) {
      filters.add('Date: $_fromDate to $_toDate');
    } else if (_fromDate != null) {
      filters.add('From: $_fromDate');
    } else if (_toDate != null) {
      filters.add('To: $_toDate');
    }
    
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      filters.add('Search: "$_searchQuery"');
    }
    
    return filters.isEmpty ? 'No filters applied' : filters.join(', ');
  }
}