/// Application-wide constants
class AppConstants {
  // Storage keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String cachePrefix = 'cache_';
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Retry configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // User roles
  static const String roleAdmin = 'admin';
  static const String roleSales = 'sales';
  static const String roleLogistics = 'logistics';
  static const String roleAccounts = 'accounts';
  
  // Status values
  static const String statusActive = 'active';
  static const String statusInactive = 'inactive';
  static const String statusPending = 'pending';
  static const String statusSubmitted = 'submitted';
  static const String statusAssigned = 'assigned';
  static const String statusDelivered = 'delivered';
  static const String statusPaid = 'paid';
  static const String statusComplete = 'complete';
}
