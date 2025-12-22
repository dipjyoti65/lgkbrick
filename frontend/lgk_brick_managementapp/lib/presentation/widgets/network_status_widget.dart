import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/network_service.dart';

/// Widget that displays network status information
/// 
/// Shows a banner when there's no internet connection and provides
/// network status information to users
class NetworkStatusWidget extends StatelessWidget {
  final Widget child;

  const NetworkStatusWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkService>(
      builder: (context, networkService, _) {
        return Column(
          children: [
            if (!networkService.isConnected)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: Colors.red,
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.wifi_off,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          networkService.getConnectivityDescription(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}