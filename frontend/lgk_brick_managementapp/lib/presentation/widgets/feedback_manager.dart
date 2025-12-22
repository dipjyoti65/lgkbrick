import 'package:flutter/material.dart';

/// Feedback manager for showing consistent success, error, and info messages
/// 
/// Provides static methods to show different types of feedback messages
/// using SnackBars with consistent styling throughout the app.
class FeedbackManager {
  /// Show success message
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: Colors.green.shade600,
      icon: Icons.check_circle_outline,
      duration: duration,
      action: action,
    );
  }

  /// Show error message
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: Colors.red.shade600,
      icon: Icons.error_outline,
      duration: duration,
      action: action,
    );
  }

  /// Show warning message
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: Colors.orange.shade600,
      icon: Icons.warning_outlined,
      duration: duration,
      action: action,
    );
  }

  /// Show info message
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: Colors.blue.shade600,
      icon: Icons.info_outline,
      duration: duration,
      action: action,
    );
  }

  /// Show loading message
  static void showLoading(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: Colors.grey.shade700,
      icon: Icons.hourglass_empty,
      duration: duration,
    );
  }

  /// Show network error with retry option
  static void showNetworkError(
    BuildContext context, {
    String message = 'Network connection failed',
    VoidCallback? onRetry,
  }) {
    showError(
      context,
      message,
      duration: const Duration(seconds: 5),
      action: onRetry != null
          ? SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: onRetry,
            )
          : null,
    );
  }

  /// Show validation error
  static void showValidationError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    showError(context, message, duration: duration);
  }

  /// Show operation completed message
  static void showOperationCompleted(
    BuildContext context,
    String operation, {
    Duration duration = const Duration(seconds: 2),
  }) {
    showSuccess(context, '$operation completed successfully', duration: duration);
  }

  /// Show confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
    IconData? icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: confirmColor),
              const SizedBox(width: 8),
            ],
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: confirmColor != null
                ? ElevatedButton.styleFrom(backgroundColor: confirmColor)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Show delete confirmation dialog
  static Future<bool> showDeleteConfirmation(
    BuildContext context, {
    required String itemName,
    String? customMessage,
  }) {
    return showConfirmationDialog(
      context,
      title: 'Delete $itemName',
      message: customMessage ?? 'Are you sure you want to delete this $itemName? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      confirmColor: Colors.red.shade600,
      icon: Icons.delete_outline,
    );
  }

  /// Show logout confirmation dialog
  static Future<bool> showLogoutConfirmation(BuildContext context) {
    return showConfirmationDialog(
      context,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      cancelText: 'Cancel',
      icon: Icons.logout,
    );
  }

  static void _showSnackBar(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required IconData icon,
    required Duration duration,
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: action,
      ),
    );
  }
}

/// Extension on BuildContext for easier access to feedback methods
extension FeedbackExtension on BuildContext {
  /// Show success message
  void showSuccess(String message, {Duration? duration, SnackBarAction? action}) {
    FeedbackManager.showSuccess(this, message, duration: duration ?? const Duration(seconds: 3), action: action);
  }

  /// Show error message
  void showError(String message, {Duration? duration, SnackBarAction? action}) {
    FeedbackManager.showError(this, message, duration: duration ?? const Duration(seconds: 4), action: action);
  }

  /// Show warning message
  void showWarning(String message, {Duration? duration, SnackBarAction? action}) {
    FeedbackManager.showWarning(this, message, duration: duration ?? const Duration(seconds: 3), action: action);
  }

  /// Show info message
  void showInfo(String message, {Duration? duration, SnackBarAction? action}) {
    FeedbackManager.showInfo(this, message, duration: duration ?? const Duration(seconds: 3), action: action);
  }

  /// Show loading message
  void showLoading(String message, {Duration? duration}) {
    FeedbackManager.showLoading(this, message, duration: duration ?? const Duration(seconds: 2));
  }

  /// Show network error with retry option
  void showNetworkError({String? message, VoidCallback? onRetry}) {
    FeedbackManager.showNetworkError(this, message: message ?? 'Network connection failed', onRetry: onRetry);
  }
}