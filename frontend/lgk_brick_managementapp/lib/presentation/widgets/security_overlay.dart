import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/security_service.dart';

/// Widget that provides security overlay functionality
/// 
/// Shows a privacy screen when the app is backgrounded to prevent
/// sensitive data from being visible in app switcher
class SecurityOverlay extends StatelessWidget {
  final Widget child;

  const SecurityOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SecurityService>(
      builder: (context, securityService, _) {
        return Stack(
          children: [
            child,
            if (securityService.isAppInBackground)
              Container(
                color: Colors.white,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.business,
                        size: 80,
                        color: Colors.blue,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'LGK Brick Management',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}