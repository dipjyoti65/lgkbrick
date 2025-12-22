import 'package:flutter/foundation.dart';
import '../../data/models/requisition.dart';
import '../../data/models/delivery_challan.dart';
import '../../data/models/delivery_challan_request.dart';
import '../../data/repositories/requisition_repository.dart';
import '../../data/repositories/delivery_challan_repository.dart';
import '../../core/exceptions/app_exception.dart';

/// Provider for delivery challan management
/// 
/// Manages delivery challan operations and pending orders for logistics users.
class DeliveryChallanProvider extends ChangeNotifier {
  final RequisitionRepository? _requisitionRepository;
  final DeliveryChallanRepository? _challanRepository;

  // State
  List<Requisition> _pendingOrders = [];
  List<DeliveryChallan> _deliveryChallans = [];
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  DeliveryChallanProvider({
    RequisitionRepository? requisitionRepository,
    DeliveryChallanRepository? challanRepository,
  }) : _requisitionRepository = requisitionRepository,
       _challanRepository = challanRepository;

  // Getters
  List<Requisition> get pendingOrders => _pendingOrders;
  List<DeliveryChallan> get deliveryChallans => _deliveryChallans;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;

  /// Fetch pending orders (submitted requisitions)
  Future<void> fetchPendingOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_requisitionRepository != null) {
        // Fetch submitted requisitions that need delivery challans
        final allRequisitions = await _requisitionRepository!.getRequisitions();
        _pendingOrders = allRequisitions.where((r) => r.status == 'submitted').toList();
      } else {
        _pendingOrders = [];
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch delivery challans
  Future<void> fetchDeliveryChallans() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_challanRepository != null) {
        _deliveryChallans = await _challanRepository!.getDeliveryChallans();
      } else {
        _deliveryChallans = [];
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create delivery challan
  Future<bool> createDeliveryChallan(DeliveryChallanRequest request) async {
    _isLoading = true;
    _clearError();
    _clearSuccessMessage();
    notifyListeners();

    try {
      if (_challanRepository != null) {
        final newChallan = await _challanRepository!.createDeliveryChallan(request);
        _deliveryChallans.insert(0, newChallan);
        
        // Remove the order from pending orders
        _pendingOrders.removeWhere((order) => order.id == request.requisitionId);
        
        _setSuccessMessage('Delivery challan created successfully');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw AppException('Delivery challan repository not available');
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
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

  void _clearError() {
    _error = null;
  }

  void _clearSuccessMessage() {
    _successMessage = null;
  }

  void _setSuccessMessage(String message) {
    _successMessage = message;
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
