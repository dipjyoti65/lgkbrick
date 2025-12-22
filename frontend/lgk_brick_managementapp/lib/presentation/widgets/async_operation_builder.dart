import 'package:flutter/material.dart';
import 'loading_overlay.dart';
import 'message_display.dart';

/// Builder widget for handling async operations with loading, error, and success states
/// 
/// Provides a consistent way to handle async operations throughout the app
/// with automatic loading indicators, error handling, and success feedback.
class AsyncOperationBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final String? loadingMessage;
  final bool showLoadingOverlay;
  final VoidCallback? onRetry;

  const AsyncOperationBuilder({
    super.key,
    required this.future,
    required this.builder,
    this.errorBuilder,
    this.loadingBuilder,
    this.loadingMessage,
    this.showLoadingOverlay = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          final loadingWidget = loadingBuilder?.call(context) ??
              LoadingIndicator(message: loadingMessage);

          if (showLoadingOverlay) {
            return LoadingOverlay(
              isLoading: true,
              message: loadingMessage,
              child: const SizedBox.shrink(),
            );
          }

          return Center(child: loadingWidget);
        }

        if (snapshot.hasError) {
          final errorWidget = errorBuilder?.call(context, snapshot.error!) ??
              ErrorStateDisplay(
                title: 'Something went wrong',
                subtitle: snapshot.error.toString(),
                onRetry: onRetry,
              );

          return errorWidget;
        }

        if (snapshot.hasData) {
          return builder(context, snapshot.data as T);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

/// Widget for handling provider state with loading, error, and data states
class ProviderStateBuilder<T> extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final T? data;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context, String error)? errorBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final String? loadingMessage;
  final VoidCallback? onRetry;
  final bool Function(T data)? isEmpty;

  const ProviderStateBuilder({
    super.key,
    required this.isLoading,
    required this.error,
    required this.data,
    required this.builder,
    this.errorBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
    this.loadingMessage,
    this.onRetry,
    this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && data == null) {
      return loadingBuilder?.call(context) ??
          Center(child: LoadingIndicator(message: loadingMessage));
    }

    if (error != null) {
      return errorBuilder?.call(context, error!) ??
          ErrorStateDisplay(
            title: 'Error occurred',
            subtitle: error,
            onRetry: onRetry,
          );
    }

    if (data == null) {
      return emptyBuilder?.call(context) ??
          const EmptyStateDisplay(
            title: 'No data available',
            icon: Icons.inbox_outlined,
          );
    }

    // Check if data is empty using custom isEmpty function
    if (isEmpty != null && isEmpty!(data!)) {
      return emptyBuilder?.call(context) ??
          const EmptyStateDisplay(
            title: 'No data available',
            icon: Icons.inbox_outlined,
          );
    }

    return builder(context, data!);
  }
}

/// Widget for handling list data with loading, error, and empty states
class ListStateBuilder<T> extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final List<T> items;
  final Widget Function(BuildContext context, List<T> items) builder;
  final Widget Function(BuildContext context, String error)? errorBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final String? loadingMessage;
  final String? emptyMessage;
  final IconData? emptyIcon;
  final VoidCallback? onRetry;
  final VoidCallback? onRefresh;

  const ListStateBuilder({
    super.key,
    required this.isLoading,
    required this.error,
    required this.items,
    required this.builder,
    this.errorBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
    this.loadingMessage,
    this.emptyMessage,
    this.emptyIcon,
    this.onRetry,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && items.isEmpty) {
      return loadingBuilder?.call(context) ??
          Center(child: LoadingIndicator(message: loadingMessage));
    }

    if (error != null && items.isEmpty) {
      return errorBuilder?.call(context, error!) ??
          ErrorStateDisplay(
            title: 'Failed to load data',
            subtitle: error,
            onRetry: onRetry,
          );
    }

    if (items.isEmpty) {
      return emptyBuilder?.call(context) ??
          EmptyStateDisplay(
            title: emptyMessage ?? 'No items found',
            icon: emptyIcon ?? Icons.inbox_outlined,
            onAction: onRefresh,
            actionText: onRefresh != null ? 'Refresh' : null,
          );
    }

    Widget content = builder(context, items);

    // Wrap with RefreshIndicator if onRefresh is provided
    if (onRefresh != null) {
      content = RefreshIndicator(
        onRefresh: () async {
          onRefresh!();
        },
        child: content,
      );
    }

    return content;
  }
}

/// Mixin for handling async operations in StatefulWidgets
mixin AsyncOperationMixin<T extends StatefulWidget> on State<T> {
  /// Execute an async operation with loading state management
  Future<R?> executeAsync<R>(
    Future<R> Function() operation, {
    String? loadingMessage,
    String? successMessage,
    bool showLoadingFeedback = false,
    bool showSuccessFeedback = true,
    bool showErrorFeedback = true,
  }) async {
    try {
      if (showLoadingFeedback && loadingMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text(loadingMessage),
              ],
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }

      final result = await operation();

      if (showSuccessFeedback && successMessage != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(successMessage),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }

      return result;
    } catch (error) {
      if (mounted && showErrorFeedback) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(error.toString())),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return null;
    }
  }
}