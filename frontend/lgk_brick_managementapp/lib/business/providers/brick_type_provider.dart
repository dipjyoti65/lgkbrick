import 'package:flutter/foundation.dart';
import '../../data/models/brick_type.dart';
import '../../data/models/brick_type_request.dart';
import '../../data/repositories/brick_type_repository.dart';
import '../../core/exceptions/app_exception.dart';

/// Provider for brick type management state
/// 
/// Manages brick type CRUD operations, pricing updates, status management,
/// and filtering functionality for admin users.
class BrickTypeProvider extends ChangeNotifier {
  final BrickTypeRepository _brickTypeRepository;

  // State
  List<BrickType> _brickTypes = [];
  List<BrickType> _activeBrickTypes = [];
  BrickType? _selectedBrickType;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;
  ValidationException? _lastValidationException; // Store the last validation exception

  // Filters
  String? _searchQuery;
  String? _filterStatus;
  String? _filterCategory;

  BrickTypeProvider({required BrickTypeRepository brickTypeRepository})
      : _brickTypeRepository = brickTypeRepository;

  // Getters
  List<BrickType> get brickTypes => _brickTypes;
  List<BrickType> get activeBrickTypes => _activeBrickTypes;
  BrickType? get selectedBrickType => _selectedBrickType;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  ValidationException? get lastValidationException => _lastValidationException;
  String? get searchQuery => _searchQuery;
  String? get filterStatus => _filterStatus;
  String? get filterCategory => _filterCategory;

  /// Fetch brick types with current filters
  Future<void> fetchBrickTypes() async {
    _setLoading(true);
    _clearError();
    _clearSuccessMessage();

    try {
      _brickTypes = await _brickTypeRepository.getBrickTypes(
        search: _searchQuery,
        status: _filterStatus,
        category: _filterCategory,
      );
      _setLoading(false);
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
    }
  }

  /// Fetch active brick types only
  Future<void> fetchActiveBrickTypes() async {
    _setLoading(true);
    _clearError();

    try {
      _activeBrickTypes = await _brickTypeRepository.getActiveBrickTypes();
      _setLoading(false);
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
    }
  }

  /// Create new brick type
  Future<bool> createBrickType(BrickTypeRequest request) async {
    _setLoading(true);
    _clearError();
    _clearSuccessMessage();

    try {
      final newBrickType = await _brickTypeRepository.createBrickType(request);
      _brickTypes.insert(0, newBrickType);
      if (newBrickType.isActive) {
        _activeBrickTypes.insert(0, newBrickType);
      }
      _setSuccessMessage('Brick type created successfully');
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  /// Update existing brick type
  Future<bool> updateBrickType(
    int id,
    BrickTypeRequest request,
  ) async {
    _setLoading(true);
    _clearError();
    _clearSuccessMessage();

    try {
      final updatedBrickType = await _brickTypeRepository.updateBrickType(
        id,
        request,
      );
      final index = _brickTypes.indexWhere((bt) => bt.id == id);
      if (index != -1) {
        _brickTypes[index] = updatedBrickType;
      }
      if (_selectedBrickType?.id == id) {
        _selectedBrickType = updatedBrickType;
      }
      
      // Update active list
      final activeIndex = _activeBrickTypes.indexWhere((bt) => bt.id == id);
      if (updatedBrickType.isActive) {
        if (activeIndex != -1) {
          _activeBrickTypes[activeIndex] = updatedBrickType;
        } else {
          _activeBrickTypes.add(updatedBrickType);
        }
      } else {
        if (activeIndex != -1) {
          _activeBrickTypes.removeAt(activeIndex);
        }
      }
      
      _setSuccessMessage('Brick type updated successfully');
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  /// Update brick type status
  Future<bool> updateBrickTypeStatus(int id, String status) async {
    _setLoading(true);
    _clearError();
    _clearSuccessMessage();

    try {
      final updatedBrickType = await _brickTypeRepository.updateBrickTypeStatus(
        id,
        status,
      );
      final index = _brickTypes.indexWhere((bt) => bt.id == id);
      if (index != -1) {
        _brickTypes[index] = updatedBrickType;
      }
      if (_selectedBrickType?.id == id) {
        _selectedBrickType = updatedBrickType;
      }
      
      // Update active list
      final activeIndex = _activeBrickTypes.indexWhere((bt) => bt.id == id);
      if (updatedBrickType.isActive) {
        if (activeIndex == -1) {
          _activeBrickTypes.add(updatedBrickType);
        } else {
          _activeBrickTypes[activeIndex] = updatedBrickType;
        }
      } else {
        if (activeIndex != -1) {
          _activeBrickTypes.removeAt(activeIndex);
        }
      }
      
      _setSuccessMessage('Brick type status updated successfully');
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  /// Update brick type price with validation
  Future<bool> updateBrickTypePrice(int id, String newPrice) async {
    _setLoading(true);
    _clearError();
    _clearSuccessMessage();

    try {
      // Validate price format
      final priceValue = double.tryParse(newPrice);
      if (priceValue == null || priceValue <= 0) {
        _setError('Invalid price. Please enter a valid positive number.');
        _setLoading(false);
        return false;
      }

      final updatedBrickType = await _brickTypeRepository.updateBrickTypePrice(
        id,
        newPrice,
      );
      final index = _brickTypes.indexWhere((bt) => bt.id == id);
      if (index != -1) {
        _brickTypes[index] = updatedBrickType;
      }
      if (_selectedBrickType?.id == id) {
        _selectedBrickType = updatedBrickType;
      }
      
      // Update active list
      final activeIndex = _activeBrickTypes.indexWhere((bt) => bt.id == id);
      if (activeIndex != -1) {
        _activeBrickTypes[activeIndex] = updatedBrickType;
      }
      
      _setSuccessMessage('Price updated successfully');
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  /// Delete brick type
  Future<bool> deleteBrickType(int id) async {
    _setLoading(true);
    _clearError();
    _clearSuccessMessage();

    try {
      await _brickTypeRepository.deleteBrickType(id);
      _brickTypes.removeWhere((bt) => bt.id == id);
      _activeBrickTypes.removeWhere((bt) => bt.id == id);
      if (_selectedBrickType?.id == id) {
        _selectedBrickType = null;
      }
      _setSuccessMessage('Brick type deleted successfully');
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  /// Get brick type by ID
  Future<void> getBrickTypeById(int id) async {
    _setLoading(true);
    _clearError();

    try {
      _selectedBrickType = await _brickTypeRepository.getBrickTypeById(id);
      _setLoading(false);
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
    }
  }

  /// Set selected brick type
  void selectBrickType(BrickType? brickType) {
    _selectedBrickType = brickType;
    notifyListeners();
  }

  /// Clear selected brick type
  void clearSelectedBrickType() {
    _selectedBrickType = null;
    notifyListeners();
  }

  /// Set search query and refresh brick types
  Future<void> setSearchQuery(String? query) async {
    _searchQuery = query;
    notifyListeners();
    await fetchBrickTypes();
  }

  /// Set status filter and refresh brick types
  Future<void> setStatusFilter(String? status) async {
    _filterStatus = status;
    notifyListeners();
    await fetchBrickTypes();
  }

  /// Set category filter and refresh brick types
  Future<void> setCategoryFilter(String? category) async {
    _filterCategory = category;
    notifyListeners();
    await fetchBrickTypes();
  }

  /// Clear all filters and refresh brick types
  Future<void> clearFilters() async {
    _searchQuery = null;
    _filterStatus = null;
    _filterCategory = null;
    notifyListeners();
    await fetchBrickTypes();
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
      // Store the validation exception for detailed error handling
      _lastValidationException = error;
      
      // Get all field-specific errors
      final fieldErrors = error.getAllErrors();
      if (fieldErrors.isNotEmpty) {
        // Return the first field error with more context
        final firstError = fieldErrors.entries.first;
        return firstError.value;
      }
      return error.message;
    } else if (error is AppException) {
      _lastValidationException = null; // Clear validation exception
      return error.message;
    } else {
      _lastValidationException = null; // Clear validation exception
      return error.toString();
    }
  }
}
