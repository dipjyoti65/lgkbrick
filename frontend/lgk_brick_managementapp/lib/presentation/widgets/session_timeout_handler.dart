import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/security_service.dart';
import '../../business/providers/auth_provider.dart';

/// Widget that handles session timeout functionality
/// 
/// Monitors user activity and shows warnings/logout when session expires
class SessionTimeoutHandler extends StatefulWidget {
  final Widget child;

  const SessionTimeoutHandler({
    super.key,
    required this.child,
  });

  @override
  State<SessionTimeoutHandler> createState() => _SessionTimeoutHandlerState();
}

class _SessionTimeoutHandlerState extends State<SessionTimeoutHandler>
    with WidgetsBindingObserver {
  late SecurityService _securityService;
  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _securityService = Provider.of<SecurityService>(context, listen: false);
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Initialize security service with callbacks
    _securityService.initialize(
      onSessionExpired: _handleSessionExpired,
      onSessionWarning: _showSessionWarning,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _securityService.handleAppLifecycleState(state);
  }

  /// Handle session expiration
  void _handleSessionExpired() {
    if (mounted) {
      _authProvider.logout();
      _showSessionExpiredDialog();
    }
  }

  /// Show session warning dialog
  void _showSessionWarning() {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Session Warning'),
          content: const Text(
            'Your session will expire in 5 minutes due to inactivity. '
            'Would you like to extend your session?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Session will expire automatically
              },
              child: const Text('Logout'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _securityService.extendSession();
              },
              child: const Text('Extend Session'),
            ),
          ],
        ),
      );
    }
  }

  /// Show session expired dialog
  void _showSessionExpiredDialog() {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Session Expired'),
          content: const Text(
            'Your session has expired due to inactivity. '
            'Please login again to continue.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _securityService.recordActivity(),
      onPanDown: (_) => _securityService.recordActivity(),
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}