import 'package:flutter/foundation.dart';
import '../../data/models/payment.dart';
import '../../data/models/payment_request.dart';
import '../../data/models/delivery_challan.dart';
import '../../data/repositories/payment_repository.dart';
import '../../core/exceptions/app_exception.dart';

/// Provider for payment management state
/// 
/// Manages payment CRUD operations, pending challans fetching,
/// auto-fill logic, and form validation for accounts users.
class PaymentProvider extends ChangeNotifier {
  final PaymentRepository _paymentRepository;

  // State
  List<Payment> _payments = [];
  List<DeliveryChallan> _pendingChallans = [];
  List<DeliveryChallan> _allChallans = [];
  List<DeliveryChallan> _completedChallans = [];
  Payment? _selectedPayment;
  DeliveryChallan? _selectedChallan;
  bool _isLoading = false;
  bool _isFetchingPendingChallans = false;
  String? _error;
  String? _successMessage;
  
  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;

  // Form state for payment creation
  String _amountReceived = '';
  String _paymentMethod = '';
  String? _referenceNumber;
  String? _remarks;

  // Auto-filled fields from selected challan
  String _challanNumber = '';
  String _orderNumber = '';
  String _brickTypeName = '';
  String _quantity = '';
  String _customerPhone = '';
  String _customerAddress = '';
  String _vehicleNumber = '';
  String _driverName = '';
  String _totalAmount = '';

  // Validation errors
  Map<String, String> _validationErrors = {};

  // Filters
  String? _searchQuery;
  String? _filterStatus;
  String? _filterStartDate;
  String? _filterEndDate;

  PaymentProvider({
    required PaymentRepository paymentRepository,
  }) : _paymentRepository = paymentRepository;

  // Getters
  List<Payment> get payments => _payments;
  List<DeliveryChallan> get pendingChallans => _pendingChallans;
  List<DeliveryChallan> get allChallans => _allChallans;
  List<DeliveryChallan> get completedChallans => _completedChallans;
  Payment? get selectedPayment => _selectedPayment;
  DeliveryChallan? get selectedChallan => _selectedChallan;
  bool get isLoading => _isLoading;
  bool get isFetchingPendingChallans => _isFetchingPendingChallans;
  String? get error => _error;
  String? get successMessage => _successMessage;
  
  // Pagination getters
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;

  // Form state getters
  String get amountReceived => _amountReceived;
  String get paymentMethod => _paymentMethod;
  String? get referenceNumber => _referenceNumber;
  String? get remarks => _remarks;

  // Auto-filled fields getters
  String get challanNumber => _challanNumber;
  String get orderNumber => _orderNumber;
  String get brickTypeName => _brickTypeName;
  String get quantity => _quantity;
  String get customerPhone => _customerPhone;
  String get customerAddress => _customerAddress;
  String get vehicleNumber => _vehicleNumber;
  String get driverName => _driverName;
  String get totalAmount => _totalAmount;

  Map<String, String> get validationErrors => _validationErrors;

  // Filter getters
  String? get searchQuery => _searchQuery;
  String? get filterStatus => _filterStatus;
  String? get filterStartDate => _filterStartDate;
  String? get filterEndDate => _filterEndDate;

  /// Fetch payments with current filters
  Future<void> fetchPayments() async {
    _setLoading(true);
    _clearError();
    _clearSuccessMessage();

    try {
      _payments = await _paymentRepository.getPayments(
        search: _searchQuery,
        status: _filterStatus,
        startDate: _filterStartDate,
        endDate: _filterEndDate,
      );
      _setLoading(false);
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
    }
  }

  /// Fetch pending challans (that need payment processing)
  /// This should be called each time the dropdown is opened
  Future<void> fetchPendingChallans() async {
    _isFetchingPendingChallans = true;
    _clearError();
    notifyListeners();

    try {
      _pendingChallans = await _paymentRepository.getDeliveredChallans();
      
      // Clear selected challan if it's no longer in the list
      if (_selectedChallan != null && 
          !_pendingChallans.any((challan) => challan.id == _selectedChallan!.id)) {
        _selectedChallan = null;
      }
      
      _isFetchingPendingChallans = false;
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
      _isFetchingPendingChallans = false;
      notifyListeners();
    }
  }

  /// Fetch all challans with filtering and pagination
  Future<void> fetchAllChallans({
    String status = 'all',
    String? startDate,
    String? endDate,
    int page = 1,
    int perPage = 10,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _paymentRepository.getAllChallans(
        status: status,
        startDate: startDate,
        endDate: endDate,
        page: page,
        perPage: perPage,
      );

      // Update pagination info
      _currentPage = result['currentPage'] ?? page;
      _totalPages = result['totalPages'] ?? 1;
      _totalItems = result['totalItems'] ?? 0;

      // Update challans based on status
      final challans = result['challans'] as List<DeliveryChallan>;
      
      switch (status) {
        case 'all':
          _allChallans = challans;
          break;
        case 'pending':
          _pendingChallans = challans;
          break;
        case 'completed':
          _completedChallans = challans;
          break;
      }

      _setLoading(false);
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
    }
  }

  /// Get payment by ID
  Future<void> getPaymentById(int id) async {
    _setLoading(true);
    _clearError();

    try {
      _selectedPayment = await _paymentRepository.getPaymentById(id);
      _setLoading(false);
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
    }
  }

  /// Create new payment
  Future<bool> createPayment() async {
    // Validate form before submission
    if (!_validateForm()) {
      return false;
    }

    // Ensure a challan is selected
    if (_selectedChallan == null) {
      _setError('Please select a challan before processing payment');
      return false;
    }

    // Additional validation for challan ID
    if (_selectedChallan!.id == null || _selectedChallan!.id <= 0) {
      _setError('Invalid challan selected. Please select a valid challan.');
      return false;
    }

    _setLoading(true);
    _clearError();
    _clearSuccessMessage();

    try {
      // Ensure we have valid data before creating the request
      final challanId = _selectedChallan!.id;
      final totalAmountStr = _selectedChallan!.requisition?.totalAmount ?? '0';
      final totalAmount = double.tryParse(totalAmountStr) ?? 0.0;
      final amountReceived = double.tryParse(_amountReceived) ?? 0.0;

      // Debug logging for challan ID
      print('Raw challan ID: $challanId (type: ${challanId.runtimeType})');
      
      if (challanId <= 0) {
        throw Exception('Invalid challan ID: $challanId');
      }

      if (totalAmount <= 0) {
        throw Exception('Invalid total amount: $totalAmount');
      }

      final request = PaymentRequest(
        deliveryChallanId: challanId,
        totalAmount: totalAmount,
        amountReceived: amountReceived,
        paymentMethod: _paymentMethod.isEmpty ? null : _normalizePaymentMethod(_paymentMethod),
        referenceNumber: _referenceNumber,
        remarks: _remarks,
      );

      // Debug logging
      print('Selected challan ID: ${_selectedChallan?.id}');
      print('Selected challan status: ${_selectedChallan?.deliveryStatus}');
      print('Creating payment with data: ${request.toJson()}');

      final newPayment = await _paymentRepository.createPayment(request);
      _payments.insert(0, newPayment);
      _setSuccessMessage(
        'Payment recorded successfully',
      );
      _clearForm();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  /// Approve payment
  Future<bool> approvePayment(int id) async {
    _setLoading(true);
    _clearError();
    _clearSuccessMessage();

    try {
      final approvedPayment = await _paymentRepository.approvePayment(id);

      final index = _payments.indexWhere((p) => p.id == id);
      if (index != -1) {
        _payments[index] = approvedPayment;
      }
      if (_selectedPayment?.id == id) {
        _selectedPayment = approvedPayment;
      }

      _setSuccessMessage('Payment approved successfully');
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  /// Set selected challan and auto-fill form fields
  void setSelectedChallan(DeliveryChallan? challan) {
    _selectedChallan = challan;
    _clearValidationError('challan');

    if (challan != null) {
      // Auto-fill fields from selected challan
      _challanNumber = challan.challanNumber;
      _orderNumber = challan.requisition?.orderNumber ?? '';
      _brickTypeName = challan.requisition?.brickType?.name ?? '';
      _quantity = challan.requisition?.quantity ?? '';
      _customerPhone = challan.requisition?.customerPhone ?? '';
      _customerAddress = challan.requisition?.customerAddress ?? '';
      _vehicleNumber = challan.vehicleNumber;
      _driverName = challan.driverName ?? '';
      _totalAmount = challan.requisition?.totalAmount ?? '';
    } else {
      // Clear auto-filled fields
      _challanNumber = '';
      _orderNumber = '';
      _brickTypeName = '';
      _quantity = '';
      _customerPhone = '';
      _customerAddress = '';
      _vehicleNumber = '';
      _driverName = '';
      _totalAmount = '';
    }

    notifyListeners();
  }

  /// Set amount received
  void setAmountReceived(String value) {
    _amountReceived = value;
    _clearValidationError('amountReceived');
    notifyListeners();
  }

  /// Set payment method
  void setPaymentMethod(String value) {
    _paymentMethod = value;
    _clearValidationError('paymentMethod');
    notifyListeners();
  }

  /// Set reference number
  void setReferenceNumber(String? value) {
    _referenceNumber = value;
    notifyListeners();
  }

  /// Set remarks
  void setRemarks(String? value) {
    _remarks = value;
    notifyListeners();
  }

  /// Validate form fields
  bool _validateForm() {
    _validationErrors.clear();
    bool isValid = true;

    // Debug logging
    print('Validating form...');
    print('Selected challan: ${_selectedChallan?.id} - ${_selectedChallan?.challanNumber}');
    print('Amount received: $_amountReceived');

    // Validate selected challan
    if (_selectedChallan == null) {
      _validationErrors['challan'] = 'Please select a pending challan';
      isValid = false;
      print('Validation failed: No challan selected');
    } else if (_selectedChallan!.id == null || _selectedChallan!.id <= 0) {
      _validationErrors['challan'] = 'Invalid challan selected';
      isValid = false;
      print('Validation failed: Invalid challan ID: ${_selectedChallan!.id}');
    }

    // Validate amount received
    if (_amountReceived.isEmpty) {
      _validationErrors['amountReceived'] = 'Please enter payment amount';
      isValid = false;
    } else {
      final amount = double.tryParse(_amountReceived);
      if (amount == null || amount <= 0) {
        _validationErrors['amountReceived'] = 'Please enter a valid amount';
        isValid = false;
      } else if (_selectedChallan != null) {
        final totalAmount = double.tryParse(_totalAmount) ?? 0.0;
        if (amount > totalAmount) {
          _validationErrors['amountReceived'] =
              'Amount cannot exceed total amount (₹$totalAmount)';
          isValid = false;
        }
      }
    }

    if (!isValid) {
      notifyListeners();
    }

    return isValid;
  }

  /// Clear validation error for a specific field
  void _clearValidationError(String field) {
    _validationErrors.remove(field);
  }

  /// Clear form fields
  void clearForm() {
    _clearForm();
    notifyListeners();
  }

  void _clearForm() {
    _selectedChallan = null;
    _amountReceived = '';
    _paymentMethod = '';
    _referenceNumber = null;
    _remarks = null;
    _challanNumber = '';
    _orderNumber = '';
    _brickTypeName = '';
    _quantity = '';
    _customerPhone = '';
    _customerAddress = '';
    _vehicleNumber = '';
    _driverName = '';
    _totalAmount = '';
    _validationErrors.clear();
  }

  /// Set selected payment
  void selectPayment(Payment? payment) {
    _selectedPayment = payment;
    notifyListeners();
  }

  /// Clear selected payment
  void clearSelectedPayment() {
    _selectedPayment = null;
    notifyListeners();
  }

  /// Set search query and refresh payments
  Future<void> setSearchQuery(String? query) async {
    _searchQuery = query;
    notifyListeners();
    await fetchPayments();
  }

  /// Set status filter and refresh payments
  Future<void> setStatusFilter(String? status) async {
    _filterStatus = status;
    notifyListeners();
    await fetchPayments();
  }

  /// Set date range filter and refresh payments
  Future<void> setDateRangeFilter(String? startDate, String? endDate) async {
    _filterStartDate = startDate;
    _filterEndDate = endDate;
    notifyListeners();
    await fetchPayments();
  }

  /// Clear all filters and refresh payments
  Future<void> clearFilters() async {
    _searchQuery = null;
    _filterStatus = null;
    _filterStartDate = null;
    _filterEndDate = null;
    notifyListeners();
    await fetchPayments();
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

  /// Normalize payment method to match backend constants
  String _normalizePaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'cash';
      case 'cheque':
        return 'cheque';
      case 'bank transfer':
      case 'bank_transfer':
        return 'bank_transfer';
      case 'upi':
        return 'upi';
      default:
        return method.toLowerCase();
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is ValidationException) {
      return error.message;
    } else if (error is AppException) {
      return error.message;
    } else {
      return error.toString();
    }
  }
}


