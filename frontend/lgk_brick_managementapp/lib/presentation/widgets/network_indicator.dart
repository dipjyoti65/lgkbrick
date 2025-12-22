import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/services/network_service.dart';

/// Network connectivity indicator widget
/// 
/// Shows current network status with appropriate icons and colors.
/// Can be used in app bars, status bars, or as standalone indicators.
class NetworkIndicator extends StatelessWidget {
  final bool showText;
  final bool showIcon;
  final double iconSize;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;

  const NetworkIndicator({
    super.key,
    this.showText = true,
    this.showIcon = true,
    this.iconSize = 16,
    this.textStyle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkService>(
      builder: (context, networkService, child) {
        final isConnected = networkService.isConnected;
        final description = networkService.getConnectivityDescription();
        
        return Container(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showIcon) ...[
                Icon(
                  _getNetworkIcon(networkService.connectionStatus, isConnected),
                  size: iconSize,
                  color: _getNetworkColor(isConnected),
                ),
                if (showText) const SizedBox(width: 4),
              ],
              if (showText)
                Text(
                  description,
                  style: (textStyle ?? Theme.of(context).textTheme.bodySmall)?.copyWith(
                    color: _getNetworkColor(isConnected),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  IconData _getNetworkIcon(ConnectivityResult connectionStatus, bool isConnected) {
    if (!isConnected) {
      return Icons.wifi_off;
    }

    switch (connectionStatus) {
      case ConnectivityResult.wifi:
        return Icons.wifi;
      case ConnectivityResult.mobile:
        return Icons.signal_cellular_4_bar;
      case ConnectivityResult.ethernet:
        return Icons.settings_ethernet;
      default:
        return Icons.wifi_off;
    }
  }

  Color _getNetworkColor(bool isConnected) {
    return isConnected ? Colors.green : Colors.red;
  }
}

/// Compact network status dot indicator
class NetworkStatusDot extends StatelessWidget {
  final double size;
  final EdgeInsetsGeometry? margin;

  const NetworkStatusDot({
    super.key,
    this.size = 8,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkService>(
      builder: (context, networkService, child) {
        return Container(
          margin: margin,
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: networkService.isConnected ? Colors.green : Colors.red,
          ),
        );
      },
    );
  }
}

/// Network status banner that appears at the top of the screen
class NetworkStatusBanner extends StatelessWidget {
  final Widget child;
  final bool persistent;
  final Duration animationDuration;

  const NetworkStatusBanner({
    super.key,
    required this.child,
    this.persistent = false,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkService>(
      builder: (context, networkService, _) {
        final isConnected = networkService.isConnected;
        
        return Column(
          children: [
            AnimatedContainer(
              duration: animationDuration,
              height: (!isConnected || persistent) ? null : 0,
              child: (!isConnected || persistent)
                  ? Material(
                      color: isConnected ? Colors.green.shade600 : Colors.red.shade600,
                      child: SafeArea(
                        bottom: false,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isConnected ? Icons.wifi : Icons.wifi_off,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  isConnected
                                      ? 'Connection restored'
                                      : networkService.getConnectivityDescription(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (isConnected && !persistent)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}

/// Network-aware refresh indicator
class NetworkAwareRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final String? offlineMessage;

  const NetworkAwareRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.offlineMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkService>(
      builder: (context, networkService, _) {
        if (!networkService.isConnected) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wifi_off,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No Internet Connection',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  offlineMessage ?? 'Pull to refresh when connection is restored',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: onRefresh,
          child: child,
        );
      },
    );
  }
}

/// Floating action button with network awareness
class NetworkAwareFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const NetworkAwareFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkService>(
      builder: (context, networkService, _) {
        final isEnabled = networkService.isConnected && onPressed != null;
        
        return FloatingActionButton(
          onPressed: isEnabled ? onPressed : null,
          tooltip: isEnabled 
              ? tooltip 
              : 'No internet connection',
          backgroundColor: isEnabled 
              ? backgroundColor 
              : Colors.grey.shade400,
          foregroundColor: isEnabled 
              ? foregroundColor 
              : Colors.grey.shade600,
          child: Stack(
            children: [
              child,
              if (!networkService.isConnected)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: const Icon(
                      Icons.wifi_off,
                      size: 8,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}