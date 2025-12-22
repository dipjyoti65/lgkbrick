import 'package:flutter/foundation.dart';
import '../../data/models/user.dart';
import '../../data/models/role.dart';
import '../../data/models/department.dart';
import '../../data/models/user_request.dart';
import '../../data/repositories/user_repository.dart';
import '../../core/exceptions/app_exception.dart';

/// Provider for user management state
/// 
/// Manages user CRUD operations, role and department management,
/// and user filtering/search functionality for admin users.
class UserManagementProvider extends ChangeNotifier {
  final UserRepository _userRepository;

  // State
  List<User> _users = [];
  List<Role> _roles = [];
  List<Department> _departments = [];
  User? _selectedUser;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;
  ValidationException? _lastValidationException; // Store the last validation exception

  // Filters
  String? _searchQuery;
  int? _filterRoleId;
  int? _filterDepartmentId;
  String? _filterStatus;

  UserManagementProvider({required UserRepository userRepository})
      : _userRepository = userRepository;

  // Getters
  List<User> get users => _users;
  List<Role> get roles => _roles;
  List<Department> get departments => _departments;
  User? get selectedUser => _selectedUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  ValidationException? get lastValidationException => _lastValidationException;
  String? get searchQuery => _searchQuery;
  int? get filterRoleId => _filterRoleId;
  int? get filterDepartmentId => _filterDepartmentId;
  String? get filterStatus => _filterStatus;

  /// Initialize provider by loading form data
  Future<void> initialize() async {
    await loadFormData();
  }

  /// Load roles and departments for form dropdowns
  Future<void> loadFormData() async {
    _setLoading(true);
    _clearError();

    try {
      final formData = await _userRepository.getUserFormData();
      _roles = formData.roles;
      _departments = formData.departments;
      _setLoading(false);
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
    }
  }

  /// Fetch users with current filters
  Future<void> fetchUsers() async {
    _setLoading(true);
    _clearError();
    _clearSuccessMessage();

    try {
      _users = await _userRepository.getUsers(
        search: _searchQuery,
        roleId: _filterRoleId,
        departmentId: _filterDepartmentId,
        status: _filterStatus,
      );
      _setLoading(false);
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
    }
  }

  /// Create new user
  Future<bool> createUser(CreateUserRequest request) async {
    _setLoading(true);
    _clearError();
    _clearSuccessMessage();

    try {
      final newUser = await _userRepository.createUser(request);
      _users.insert(0, newUser);
      _setSuccessMessage('User created successfully');
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  /// Update existing user
  Future<bool> updateUser(int id, UpdateUserRequest request) async {
    _setLoading(true);
    _clearError();
    _clearSuccessMessage();

    try {
      final updatedUser = await _userRepository.updateUser(id, request);
      final index = _users.indexWhere((u) => u.id == id);
      if (index != -1) {
        _users[index] = updatedUser;
      }
      if (_selectedUser?.id == id) {
        _selectedUser = updatedUser;
      }
      _setSuccessMessage('User updated successfully');
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  /// Update user status (activate/deactivate)
  Future<bool> updateUserStatus(int id, String status) async {
    _setLoading(true);
    _clearError();
    _clearSuccessMessage();

    try {
      final updatedUser = await _userRepository.updateUserStatus(id, status);
      final index = _users.indexWhere((u) => u.id == id);
      if (index != -1) {
        _users[index] = updatedUser;
      }
      if (_selectedUser?.id == id) {
        _selectedUser = updatedUser;
      }
      _setSuccessMessage('User status updated successfully');
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  /// Delete user
  Future<bool> deleteUser(int id) async {
    _setLoading(true);
    _clearError();
    _clearSuccessMessage();

    try {
      await _userRepository.deleteUser(id);
      _users.removeWhere((u) => u.id == id);
      if (_selectedUser?.id == id) {
        _selectedUser = null;
      }
      _setSuccessMessage('User deleted successfully');
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  /// Get user by ID
  Future<void> getUserById(int id) async {
    _setLoading(true);
    _clearError();

    try {
      _selectedUser = await _userRepository.getUserById(id);
      _setLoading(false);
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
    }
  }

  /// Set selected user for editing
  void selectUser(User? user) {
    _selectedUser = user;
    notifyListeners();
  }

  /// Clear selected user
  void clearSelectedUser() {
    _selectedUser = null;
    notifyListeners();
  }

  /// Set search query and refresh users
  Future<void> setSearchQuery(String? query) async {
    _searchQuery = query;
    notifyListeners();
    await fetchUsers();
  }

  /// Set role filter and refresh users
  Future<void> setRoleFilter(int? roleId) async {
    _filterRoleId = roleId;
    notifyListeners();
    await fetchUsers();
  }

  /// Set department filter and refresh users
  Future<void> setDepartmentFilter(int? departmentId) async {
    _filterDepartmentId = departmentId;
    notifyListeners();
    await fetchUsers();
  }

  /// Set status filter and refresh users
  Future<void> setStatusFilter(String? status) async {
    _filterStatus = status;
    notifyListeners();
    await fetchUsers();
  }

  /// Clear all filters and refresh users
  Future<void> clearFilters() async {
    _searchQuery = null;
    _filterRoleId = null;
    _filterDepartmentId = null;
    _filterStatus = null;
    notifyListeners();
    await fetchUsers();
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
