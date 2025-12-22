import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business/providers/auth_provider.dart';

/// Widget that conditionally renders content based on user role
/// 
/// Provides a declarative way to show/hide UI elements based on
/// the current user's role and permissions.
class RoleBasedWidget extends StatelessWidget {
  /// List of roles that can see this widget
  final List<String> allowedRoles;

  /// Widget to display when user has required role
  final Widget child;

  /// Optional widget to display when user doesn't have required role
  final Widget? fallback;

  const RoleBasedWidget({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userRole = authProvider.currentUser?.role?.name?.toLowerCase();

    // Check if user has one of the allowed roles
    final hasAccess = userRole != null &&
        allowedRoles.any((role) => role.toLowerCase() == userRole);

    if (hasAccess) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}

/// Widget that shows content only to admin users
class AdminOnlyWidget extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const AdminOnlyWidget({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return RoleBasedWidget(
      allowedRoles: const ['admin'],
      fallback: fallback,
      child: child,
    );
  }
}

/// Widget that shows content only to sales users
class SalesOnlyWidget extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const SalesOnlyWidget({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return RoleBasedWidget(
      allowedRoles: const ['sales', 'sales executive'],
      fallback: fallback,
      child: child,
    );
  }
}

/// Widget that shows content only to logistics users
class LogisticsOnlyWidget extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const LogisticsOnlyWidget({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return RoleBasedWidget(
      allowedRoles: const ['logistics'],
      fallback: fallback,
      child: child,
    );
  }
}

/// Widget that shows content only to accounts users
class AccountsOnlyWidget extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const AccountsOnlyWidget({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return RoleBasedWidget(
      allowedRoles: const ['accounts'],
      fallback: fallback,
      child: child,
    );
  }
}
