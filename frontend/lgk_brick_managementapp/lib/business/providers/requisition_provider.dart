import 'package:flutter/foundation.dart';
import '../../data/models/requisition.dart';
import '../../data/models/requisition_request.dart';
import '../../data/models/brick_type.dart';
import '../../data/repositories/requisition_repository.dart';
import '../../core/exceptions/app_exception.dart';

/// Provider for requisition management state
/// 
/// Manages requisition CRUD operations, form validation, total calculation,
/// and filtering functionality for sales users.
class RequisitionProvider extends ChangeNotifier {
  final RequisitionRepository _requisitionRepository;

  // State
  List<Requisition> _requisitions = [];
  Requisition? _selectedRequisition;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  // Form state for requisition creation
  BrickType? _selectedBrickType;
  String _quantity = '';
  String _enteredPrice = '';
  String _customerName = '';
  String _customerPhone = '';
  String _customerAddress = '';
  String? _customerLocation;
  double _calculatedTotal = 0.0;

  // Validation errors
  Map<String, String> _validationErrors = {};

  // Filters
  String? _searchQuery;
  String? _filterStatus;
  int? _filterUserId;
  int? _filterBrickTypeId;

  RequisitionProvider({required RequisitionRepository requisitionRepository})
      : _requisitionRepository = requisitionRepository;

  // Getters
  List<Requisition> get requisitions => _requisitions;
  Requisition? get selectedRequisition => _selectedRequisition;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  
  // Form state getters
  BrickType? get selectedBrickType => _selectedBrickType;
  String get quantity => _quantity;
  String get enteredPrice => _enteredPrice;
  String get customerName => _customerName;
  String get customerPhone => _customerPhone;
  String get customerAddress => _customerAddress;
  String? get customerLocation => _customerLocation;
  double get calculatedTotal => _calculatedTotal;
  Map<String, String> get validationErrors => _validationErrors;
  
  // Filter getters
  String? get searchQuery => _searchQuery;
  String? get filterStatus => _filterStatus;
  int? get filterUserId => _filterUserId;
  int? get filterBrickTypeId => _filterBrickTypeId;

  /// Fetch requisitions with current filters
  Future<void> fetchRequisitions() async {
    _setLoading(true);
    _clearError();
    _clearSuccessMessage();

    try {
      _requisitions = await _requisitionRepository.getRequisitions(
        search: _searchQuery,
        status: _filterStatus,
        userId: _filterUserId,
        brickTypeId: _filterBrickTypeId,
      );
      _setLoading(false);
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
    }
  }

  /// Fetch pending requisitions (for logistics)
  Future<void> fetchPendingRequisitions() async {
    _setLoading(true);
    _clearError();

    try {
      _requisitions = await _requisitionRepository.getPendingRequisitions();
      _setLoading(false);
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
    }
  }

  /// Get requisition by ID
  Future<void> getRequisitionById(int id) async {
    _setLoading(true);
    _clearError();

    try {
      _selectedRequisition = await _requisitionRepository.getRequisitionById(id);
      _setLoading(false);
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
    }
  }

  /// Create new requisition
  Future<bool> createRequisition() async {
    // Validate form before submission
    if (!_validateForm()) {
      return false;
    }

    _setLoading(true);
    _clearError();
    _clearSuccessMessage();

    try {
      final request = RequisitionRequest(
        brickTypeId: _selectedBrickType!.id,
        quantity: _quantity,
        pricePerUnit: _selectedBrickType!.currentPrice ?? '0',
        enteredPrice: _enteredPrice,
        totalAmount: _calculatedTotal.toStringAsFixed(2),
        customerName: _customerName,
        customerPhone: _customerPhone,
        customerAddress: _customerAddress,
        customerLocation: _customerLocation ?? '',
      );

      final newRequisition = await _requisitionRepository.createRequisition(request);
      _requisitions.insert(0, newRequisition);
      _setSuccessMessage('Requisition created successfully with order number ${newRequisition.orderNumber}');
      _clearForm();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  /// Update existing requisition (only if not submitted)
  Future<bool> updateRequisition(int id) async {
    // Validate form before submission
    if (!_validateForm()) {
      return false;
    }

    _setLoading(true);
    _clearError();
    _clearSuccessMessage();

    try {
      final request = RequisitionRequest(
        brickTypeId: _selectedBrickType!.id,
        quantity: _quantity,
        pricePerUnit: _selectedBrickType!.currentPrice ?? '0',
        enteredPrice: _enteredPrice,
        totalAmount: _calculatedTotal.toStringAsFixed(2),
        customerName: _customerName,
        customerPhone: _customerPhone,
        customerAddress: _customerAddress,
        customerLocation: _customerLocation ?? '',
      );

      final updatedRequisition = await _requisitionRepository.updateRequisition(
        id,
        UpdateRequisitionRequest(
          brickTypeId: request.brickTypeId,
          quantity: request.quantity,
          pricePerUnit: request.pricePerUnit,
          enteredPrice: request.enteredPrice,
          totalAmount: request.totalAmount,
          customerName: request.customerName,
          customerPhone: request.customerPhone,
          customerAddress: request.customerAddress,
          customerLocation: request.customerLocation,
        ),
      );

      final index = _requisitions.indexWhere((r) => r.id == id);
      if (index != -1) {
        _requisitions[index] = updatedRequisition;
      }
      if (_selectedRequisition?.id == id) {
        _selectedRequisition = updatedRequisition;
      }

      _setSuccessMessage('Requisition updated successfully');
      _clearForm();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  /// Delete requisition
  Future<bool> deleteRequisition(int id) async {
    _setLoading(true);
    _clearError();
    _clearSuccessMessage();

    try {
      await _requisitionRepository.deleteRequisition(id);
      _requisitions.removeWhere((r) => r.id == id);
      if (_selectedRequisition?.id == id) {
        _selectedRequisition = null;
      }
      _setSuccessMessage('Requisition deleted successfully');
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  /// Set selected brick type and auto-populate entered price
  void setSelectedBrickType(BrickType? brickType) {
    _selectedBrickType = brickType;
    // Auto-populate entered price with current brick price as suggestion
    // Only auto-populate if the price is greater than 0
    if (brickType != null && brickType.currentPrice != null) {
      final price = double.tryParse(brickType.currentPrice!) ?? 0.0;
      if (price > 0) {
        _enteredPrice = brickType.currentPrice!;
      } else {
        _enteredPrice = '';
      }
    } else {
      _enteredPrice = '';
    }
    _calculateTotal();
    _clearValidationError('brickType');
    notifyListeners();
  }

  /// Set quantity and recalculate total
  void setQuantity(String value) {
    _quantity = value;
    _calculateTotal();
    _clearValidationError('quantity');
    notifyListeners();
  }

  /// Set entered price and recalculate total
  void setEnteredPrice(String value) {
    _enteredPrice = value;
    _calculateTotal();
    _clearValidationError('enteredPrice');
    notifyListeners();
  }

  /// Set customer name
  void setCustomerName(String value) {
    _customerName = value;
    _clearValidationError('customerName');
    notifyListeners();
  }

  /// Set customer phone
  void setCustomerPhone(String value) {
    _customerPhone = value;
    _clearValidationError('customerPhone');
    notifyListeners();
  }

  /// Set customer address
  void setCustomerAddress(String value) {
    _customerAddress = value;
    _clearValidationError('customerAddress');
    notifyListeners();
  }

  /// Set customer location
  void setCustomerLocation(String? value) {
    _customerLocation = value;
    notifyListeners();
  }

  /// Calculate total amount based on quantity and entered price
  void _calculateTotal() {
    if (_quantity.isNotEmpty && _enteredPrice.isNotEmpty) {
      final qty = double.tryParse(_quantity);
      final price = double.tryParse(_enteredPrice);
      if (qty != null && qty > 0 && price != null && price > 0) {
        _calculatedTotal = qty * price;
      } else {
        _calculatedTotal = 0.0;
      }
    } else {
      _calculatedTotal = 0.0;
    }
  }

  /// Validate form fields
  bool _validateForm() {
    _validationErrors.clear();
    bool isValid = true;

    // Validate brick type
    if (_selectedBrickType == null) {
      _validationErrors['brickType'] = 'Please select a brick type';
      isValid = false;
    }

    // Validate quantity
    if (_quantity.isEmpty) {
      _validationErrors['quantity'] = 'Please enter quantity';
      isValid = false;
    } else {
      final qty = double.tryParse(_quantity);
      if (qty == null || qty <= 0) {
        _validationErrors['quantity'] = 'Please enter a valid positive number';
        isValid = false;
      }
    }

    // Validate entered price
    if (_enteredPrice.isEmpty) {
      _validationErrors['enteredPrice'] = 'Please enter price';
      isValid = false;
    } else {
      final price = double.tryParse(_enteredPrice);
      if (price == null || price <= 0) {
        _validationErrors['enteredPrice'] = 'Please enter a valid positive price';
        isValid = false;
      }
    }

    // Validate customer name
    if (_customerName.isEmpty) {
      _validationErrors['customerName'] = 'Please enter customer name';
      isValid = false;
    } else if (_customerName.length < 2) {
      _validationErrors['customerName'] = 'Name must be at least 2 characters';
      isValid = false;
    }

    // Validate customer phone
    if (_customerPhone.isEmpty) {
      _validationErrors['customerPhone'] = 'Please enter customer phone';
      isValid = false;
    } else if (!_isValidPhone(_customerPhone)) {
      _validationErrors['customerPhone'] = 'Please enter a valid phone number';
      isValid = false;
    }

    // Validate customer address
    if (_customerAddress.isEmpty) {
      _validationErrors['customerAddress'] = 'Please enter customer address';
      isValid = false;
    } else if (_customerAddress.length < 5) {
      _validationErrors['customerAddress'] = 'Address must be at least 5 characters';
      isValid = false;
    }

    // Validate customer location (now required)
    if (_customerLocation == null || _customerLocation!.isEmpty) {
      _validationErrors['customerLocation'] = 'Please enter customer location';
      isValid = false;
    }

    if (!isValid) {
      notifyListeners();
    }

    return isValid;
  }

  /// Validate phone number format
  bool _isValidPhone(String phone) {
    // Remove spaces and dashes
    final cleanPhone = phone.replaceAll(RegExp(r'[\s-]'), '');
    // Check if it's a valid phone number (10-15 digits, optionally starting with +)
    return RegExp(r'^\+?\d{10,15}$').hasMatch(cleanPhone);
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
    _selectedBrickType = null;
    _quantity = '';
    _enteredPrice = '';
    _customerName = '';
    _customerPhone = '';
    _customerAddress = '';
    _customerLocation = null;
    _calculatedTotal = 0.0;
    _validationErrors.clear();
  }

  /// Set selected requisition
  void selectRequisition(Requisition? requisition) {
    _selectedRequisition = requisition;
    notifyListeners();
  }

  /// Clear selected requisition
  void clearSelectedRequisition() {
    _selectedRequisition = null;
    notifyListeners();
  }

  /// Set search query and refresh requisitions
  Future<void> setSearchQuery(String? query) async {
    _searchQuery = query;
    notifyListeners();
    await fetchRequisitions();
  }

  /// Set status filter and refresh requisitions
  Future<void> setStatusFilter(String? status) async {
    _filterStatus = status;
    notifyListeners();
    await fetchRequisitions();
  }

  /// Set user ID filter and refresh requisitions
  Future<void> setUserIdFilter(int? userId) async {
    _filterUserId = userId;
    notifyListeners();
    await fetchRequisitions();
  }

  /// Set brick type ID filter and refresh requisitions
  Future<void> setBrickTypeIdFilter(int? brickTypeId) async {
    _filterBrickTypeId = brickTypeId;
    notifyListeners();
    await fetchRequisitions();
  }

  /// Clear all filters and refresh requisitions
  Future<void> clearFilters() async {
    _searchQuery = null;
    _filterStatus = null;
    _filterUserId = null;
    _filterBrickTypeId = null;
    notifyListeners();
    await fetchRequisitions();
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
    if (error is ValidationException) {
      return error.message;
    } else if (error is AppException) {
      return error.message;
    } else {
      return error.toString();
    }
  }
}

/// Update requisition request model
class UpdateRequisitionRequest extends RequisitionRequest {
  UpdateRequisitionRequest({
    required super.brickTypeId,
    required super.quantity,
    required super.pricePerUnit,
    required super.enteredPrice,
    required super.totalAmount,
    required super.customerName,
    required super.customerPhone,
    required super.customerAddress,
    required super.customerLocation,
  });
}
