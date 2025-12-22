/// Base class for all application exceptions
class AppException implements Exception {
  final String message;
  final dynamic data;

  AppException(this.message, [this.data]);

  @override
  String toString() => message;
}

/// Network-related exceptions
class NetworkException extends AppException {
  NetworkException(super.message, [super.data]);
}

/// Authentication and authorization exceptions
class AuthenticationException extends AppException {
  AuthenticationException(super.message, [super.data]);
}

/// Validation exceptions
class ValidationException extends AppException {
  final Map<String, dynamic>? errors;

  ValidationException(String message, [dynamic data])
      : errors = data is Map<String, dynamic> ? data['errors'] : null,
        super(message, data);

  /// Get validation error for a specific field
  String? getFieldError(String field) {
    if (errors == null) return null;
    final fieldErrors = errors![field];
    if (fieldErrors is List && fieldErrors.isNotEmpty) {
      return fieldErrors.first.toString();
    }
    return fieldErrors?.toString();
  }

  /// Get all validation errors as a map
  Map<String, String> getAllErrors() {
    if (errors == null) return {};
    return errors!.map((key, value) {
      if (value is List && value.isNotEmpty) {
        return MapEntry(key, value.first.toString());
      }
      return MapEntry(key, value.toString());
    });
  }
}

/// Server error exceptions
class ServerException extends AppException {
  ServerException(super.message, [super.data]);
}

/// Local storage exceptions
class StorageException extends AppException {
  StorageException(super.message, [super.data]);
}

/// Cache-related exceptions
class CacheException extends AppException {
  CacheException(super.message, [super.data]);
}
