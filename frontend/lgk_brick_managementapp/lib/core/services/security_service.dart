import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Service for handling security best practices
/// 
/// Manages app backgrounding security, session timeouts, and sensitive data protection
class SecurityService extends ChangeNotifier {
  static const Duration _sessionTimeout = Duration(minutes: 30);
  static const Duration _warningTimeout = Duration(minutes: 25);
  
  Timer? _sessionTimer;
  Timer? _warningTimer;
  DateTime? _lastActivity;
  bool _isAppInBackground = false;
  bool _isSessionExpired = false;
  bool _showSessionWarning = false;
  
  // Callbacks for session management
  VoidCallback? _onSessionExpired;
  VoidCallback? _onSessionWarning;
  VoidCallback? _onAppBackgrounded;
  VoidCallback? _onAppForegrounded;

  // Getters
  bool get isSessionExpired => _isSessionExpired;
  bool get showSessionWarning => _showSessionWarning;
  bool get isAppInBackground => _isAppInBackground;
  DateTime? get lastActivity => _lastActivity;

  /// Initialize security service with callbacks
  void initialize({
    VoidCallback? onSessionExpired,
    VoidCallback? onSessionWarning,
    VoidCallback? onAppBackgrounded,
    VoidCallback? onAppForegrounded,
  }) {
    _onSessionExpired = onSessionExpired;
    _onSessionWarning = onSessionWarning;
    _onAppBackgrounded = onAppBackgrounded;
    _onAppForegrounded = onAppForegrounded;
    
    // Start session tracking
    _resetSessionTimer();
  }

  /// Record user activity to reset session timer
  void recordActivity() {
    _lastActivity = DateTime.now();
    _isSessionExpired = false;
    _showSessionWarning = false;
    _resetSessionTimer();
    notifyListeners();
  }

  /// Handle app lifecycle changes for backgrounding security
  void handleAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _handleAppBackgrounded();
        break;
      case AppLifecycleState.resumed:
        _handleAppForegrounded();
        break;
      case AppLifecycleState.detached:
        _handleAppBackgrounded();
        break;
      case AppLifecycleState.hidden:
        _handleAppBackgrounded();
        break;
    }
  }

  /// Handle app going to background
  void _handleAppBackgrounded() {
    if (!_isAppInBackground) {
      _isAppInBackground = true;
      
      // Hide sensitive content by triggering callback
      _onAppBackgrounded?.call();
      
      // Pause session timer while app is in background
      _pauseSessionTimer();
      
      notifyListeners();
    }
  }

  /// Handle app coming to foreground
  void _handleAppForegrounded() {
    if (_isAppInBackground) {
      _isAppInBackground = false;
      
      // Show content again
      _onAppForegrounded?.call();
      
      // Check if session expired while in background
      if (_lastActivity != null) {
        final timeSinceLastActivity = DateTime.now().difference(_lastActivity!);
        if (timeSinceLastActivity > _sessionTimeout) {
          _expireSession();
        } else {
          // Resume session timer
          _resetSessionTimer();
        }
      }
      
      notifyListeners();
    }
  }

  /// Reset session timer
  void _resetSessionTimer() {
    _cancelTimers();
    
    // Set warning timer (5 minutes before expiration)
    _warningTimer = Timer(_warningTimeout, () {
      _showSessionWarning = true;
      _onSessionWarning?.call();
      notifyListeners();
    });
    
    // Set session expiration timer
    _sessionTimer = Timer(_sessionTimeout, () {
      _expireSession();
    });
  }

  /// Pause session timer (when app is backgrounded)
  void _pauseSessionTimer() {
    _cancelTimers();
  }

  /// Cancel all timers
  void _cancelTimers() {
    _sessionTimer?.cancel();
    _warningTimer?.cancel();
    _sessionTimer = null;
    _warningTimer = null;
  }

  /// Expire the session
  void _expireSession() {
    _isSessionExpired = true;
    _showSessionWarning = false;
    _cancelTimers();
    _onSessionExpired?.call();
    notifyListeners();
  }

  /// Extend session (when user responds to warning)
  void extendSession() {
    _showSessionWarning = false;
    recordActivity();
  }

  /// Start session (after login)
  void startSession() {
    _isSessionExpired = false;
    _showSessionWarning = false;
    recordActivity();
  }

  /// End session (on logout)
  void endSession() {
    _isSessionExpired = true;
    _showSessionWarning = false;
    _lastActivity = null;
    _cancelTimers();
    notifyListeners();
  }

  /// Dispose of resources
  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }

  /// Secure logging method that filters sensitive data
  static void secureLog(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      // Filter out sensitive information from logs
      final sanitizedMessage = sanitizeLogMessage(message);
      final sanitizedError = error != null ? sanitizeLogMessage(error.toString()) : null;
      
      // Only log in debug mode
      debugPrint('SECURE_LOG: $sanitizedMessage');
      if (sanitizedError != null) {
        debugPrint('SECURE_ERROR: $sanitizedError');
      }
      if (stackTrace != null && kDebugMode) {
        debugPrint('SECURE_STACK: $stackTrace');
      }
    }
  }

  /// Sanitize log messages to remove sensitive data
  static String sanitizeLogMessage(String message) {
    // Remove common sensitive patterns
    String sanitized = message;
    
    // Remove tokens (Bearer tokens, API keys)
    sanitized = sanitized.replaceAll(RegExp(r'Bearer\s+[A-Za-z0-9\-_\.]+'), 'Bearer [REDACTED]');
    sanitized = sanitized.replaceAll(RegExp(r'token["\s]*[:=]["\s]*[A-Za-z0-9\-_\.]+'), 'token: [REDACTED]');
    
    // Remove passwords
    sanitized = sanitized.replaceAll(RegExp(r'password["\s]*[:=]["\s]*[^,\s}]+'), 'password: [REDACTED]');
    sanitized = sanitized.replaceAll(RegExp(r'"password"\s*:\s*"[^"]*"'), '"password": "[REDACTED]"');
    
    // Remove email addresses (partial)
    sanitized = sanitized.replaceAll(RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'), '[EMAIL_REDACTED]');
    
    // Remove phone numbers
    sanitized = sanitized.replaceAll(RegExp(r'\b\d{10,15}\b'), '[PHONE_REDACTED]');
    
    // Remove credit card numbers (basic pattern)
    sanitized = sanitized.replaceAll(RegExp(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b'), '[CARD_REDACTED]');
    
    return sanitized;
  }

  /// Check if a string contains sensitive data
  static bool containsSensitiveData(String data) {
    // Check for common sensitive patterns
    final sensitivePatterns = [
      RegExp(r'Bearer\s+[A-Za-z0-9\-_\.]+'),
      RegExp(r'password["\s]*[:=]'),
      RegExp(r'token["\s]*[:=]'),
      RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'),
      RegExp(r'\b\d{10,15}\b'), // Phone numbers
      RegExp(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b'), // Credit cards
    ];
    
    return sensitivePatterns.any((pattern) => pattern.hasMatch(data));
  }

  /// Secure method to clear sensitive data from memory
  static void clearSensitiveString(String? sensitiveData) {
    if (sensitiveData != null) {
      // In Dart, strings are immutable, so we can't actually clear the memory
      // But we can help with garbage collection by nullifying references
      // The actual memory clearing would need to be handled at the platform level
      sensitiveData = null;
    }
  }
}