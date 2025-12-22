import 'package:flutter_test/flutter_test.dart';
import 'package:lgk_brick_managementapp/core/services/security_service.dart';

void main() {
  group('SecurityService', () {
    late SecurityService securityService;

    setUp(() {
      securityService = SecurityService();
    });

    tearDown(() {
      securityService.dispose();
    });

    test('should initialize with correct default state', () {
      expect(securityService.isSessionExpired, false);
      expect(securityService.showSessionWarning, false);
      expect(securityService.isAppInBackground, false);
      expect(securityService.lastActivity, null);
    });

    test('should record activity and update last activity time', () {
      securityService.recordActivity();

      expect(securityService.lastActivity, isNotNull);
      expect(securityService.isSessionExpired, false);
      expect(securityService.showSessionWarning, false);
    });

    test('should start session correctly', () {
      securityService.startSession();

      expect(securityService.isSessionExpired, false);
      expect(securityService.showSessionWarning, false);
      expect(securityService.lastActivity, isNotNull);
    });

    test('should end session correctly', () {
      securityService.startSession();
      securityService.endSession();

      expect(securityService.isSessionExpired, true);
      expect(securityService.showSessionWarning, false);
      expect(securityService.lastActivity, null);
    });

    test('should extend session and clear warning', () {
      securityService.extendSession();

      expect(securityService.showSessionWarning, false);
      expect(securityService.isSessionExpired, false);
      expect(securityService.lastActivity, isNotNull);
    });

    group('Secure Logging', () {
      test('should sanitize Bearer tokens', () {
        const message = 'Authorization: Bearer abc123.def456.ghi789';
        final sanitized = SecurityService.sanitizeLogMessage(message);
        expect(sanitized, contains('[REDACTED]'));
        expect(sanitized, isNot(contains('abc123')));
      });

      test('should sanitize passwords', () {
        const message = 'password: "mySecretPassword123"';
        final sanitized = SecurityService.sanitizeLogMessage(message);
        expect(sanitized, contains('[REDACTED]'));
        expect(sanitized, isNot(contains('mySecretPassword123')));
      });

      test('should sanitize email addresses', () {
        const message = 'User email: user@example.com';
        final sanitized = SecurityService.sanitizeLogMessage(message);
        expect(sanitized, contains('[EMAIL_REDACTED]'));
        expect(sanitized, isNot(contains('user@example.com')));
      });

      test('should sanitize phone numbers', () {
        const message = 'Phone: 1234567890';
        final sanitized = SecurityService.sanitizeLogMessage(message);
        expect(sanitized, contains('[PHONE_REDACTED]'));
        expect(sanitized, isNot(contains('1234567890')));
      });

      test('should detect sensitive data', () {
        expect(SecurityService.containsSensitiveData('Bearer token123'), true);
        expect(SecurityService.containsSensitiveData('password: secret'), true);
        expect(SecurityService.containsSensitiveData('user@example.com'), true);
        expect(SecurityService.containsSensitiveData('1234567890123'), true); // 13 digits
        expect(SecurityService.containsSensitiveData('normal message'), false);
      });
    });
  });
}