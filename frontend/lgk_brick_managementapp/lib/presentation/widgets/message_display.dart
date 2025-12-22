import 'package:flutter/material.dart';

/// Message display widget for showing error, success, info, and warning messages
/// 
/// Provides consistent styling for different types of messages throughout the app.
class MessageDisplay extends StatelessWidget {
  final String message;
  final MessageType type;
  final VoidCallback? onDismiss;
  final VoidCallback? onRetry;
  final bool showIcon;
  final EdgeInsetsGeometry? margin;

  const MessageDisplay({
    super.key,
    required this.message,
    required this.type,
    this.onDismiss,
    this.onRetry,
    this.showIcon = true,
    this.margin,
  });

  /// Factory constructor for error messages
  factory MessageDisplay.error(
    String message, {
    VoidCallback? onDismiss,
    VoidCallback? onRetry,
    EdgeInsetsGeometry? margin,
  }) {
    return MessageDisplay(
      message: message,
      type: MessageType.error,
      onDismiss: onDismiss,
      onRetry: onRetry,
      margin: margin,
    );
  }

  /// Factory constructor for success messages
  factory MessageDisplay.success(
    String message, {
    VoidCallback? onDismiss,
    EdgeInsetsGeometry? margin,
  }) {
    return MessageDisplay(
      message: message,
      type: MessageType.success,
      onDismiss: onDismiss,
      margin: margin,
    );
  }

  /// Factory constructor for info messages
  factory MessageDisplay.info(
    String message, {
    VoidCallback? onDismiss,
    EdgeInsetsGeometry? margin,
  }) {
    return MessageDisplay(
      message: message,
      type: MessageType.info,
      onDismiss: onDismiss,
      margin: margin,
    );
  }

  /// Factory constructor for warning messages
  factory MessageDisplay.warning(
    String message, {
    VoidCallback? onDismiss,
    EdgeInsetsGeometry? margin,
  }) {
    return MessageDisplay(
      message: message,
      type: MessageType.warning,
      onDismiss: onDismiss,
      margin: margin,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getColors(context);
    
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showIcon) ...[
            Icon(
              colors.icon,
              color: colors.iconColor,
              size: 20,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: colors.textColor,
                fontSize: 14,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  color: colors.iconColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (onDismiss != null) ...[
            const SizedBox(width: 4),
            InkWell(
              onTap: onDismiss,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.close,
                  color: colors.iconColor,
                  size: 16,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  _MessageColors _getColors(BuildContext context) {
    switch (type) {
      case MessageType.error:
        return _MessageColors(
          backgroundColor: Colors.red.shade50,
          borderColor: Colors.red.shade200,
          textColor: Colors.red.shade800,
          iconColor: Colors.red.shade700,
          icon: Icons.error_outline,
        );
      case MessageType.success:
        return _MessageColors(
          backgroundColor: Colors.green.shade50,
          borderColor: Colors.green.shade200,
          textColor: Colors.green.shade800,
          iconColor: Colors.green.shade700,
          icon: Icons.check_circle_outline,
        );
      case MessageType.warning:
        return _MessageColors(
          backgroundColor: Colors.orange.shade50,
          borderColor: Colors.orange.shade200,
          textColor: Colors.orange.shade800,
          iconColor: Colors.orange.shade700,
          icon: Icons.warning_outlined,
        );
      case MessageType.info:
        return _MessageColors(
          backgroundColor: Colors.blue.shade50,
          borderColor: Colors.blue.shade200,
          textColor: Colors.blue.shade800,
          iconColor: Colors.blue.shade700,
          icon: Icons.info_outline,
        );
    }
  }
}

/// Empty state widget for when there's no data to display
class EmptyStateDisplay extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionText;

  const EmptyStateDisplay({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh),
                label: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state widget for when an error occurs
class ErrorStateDisplay extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onRetry;
  final String? retryText;

  const ErrorStateDisplay({
    super.key,
    required this.title,
    this.subtitle,
    this.onRetry,
    this.retryText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.red.shade700,
                  ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.red.shade600,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryText ?? 'Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum MessageType {
  error,
  success,
  warning,
  info,
}

class _MessageColors {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color iconColor;
  final IconData icon;

  _MessageColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.iconColor,
    required this.icon,
  });
}