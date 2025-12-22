import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../business/providers/order_history_provider.dart';
import '../../data/models/order_history.dart';
import '../../core/utils/formatters.dart';
import '../../core/di/service_locator.dart';
import '../widgets/order_filter_drawer.dart';
import 'order_details_screen.dart';
import 'order_statistics_screen.dart';

/// Order History screen for Admin users
/// 
/// Displays comprehensive order history with filtering capabilities,
/// statistics, and detailed order information access.
class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _debounceTimer;
  static const int _searchDebounceMs = 500; // 500ms debounce
  static const int _minSearchLength = 3; // Minimum 3 characters

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<OrderHistoryProvider>();
      provider.fetchOrderHistory();
      // Don't fetch statistics automatically - only when user opens statistics screen
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Order History'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back to Dashboard',
        ),
        actions: [
          // Filter/Menu icon
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            tooltip: 'Filters',
          ),
          // Statistics icon
          Consumer<OrderHistoryProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: const Icon(Icons.analytics),
                onPressed: () => _navigateToStatistics(),
                tooltip: 'View Statistics',
              );
            },
          ),
          Consumer<OrderHistoryProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: const Icon(Icons.file_download),
                onPressed: provider.isLoading ? null : () => _showExportDialog(),
                tooltip: 'Export to Excel',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshData(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: const OrderFilterDrawer(),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(child: _buildOrderList()),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        children: [
          // Search field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search orders, customers, sales executives...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: _onSearchChanged,
            onSubmitted: (value) => _performSearch(value),
          ),
          
          // Filter summary
          Consumer<OrderHistoryProvider>(
            builder: (context, provider, child) {
              if (!provider.hasActiveFilters) return const SizedBox.shrink();
              
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.filter_list, 
                         size: 16, 
                         color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        provider.filterSummary,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        provider.clearFilters();
                        _searchController.clear();
                        _debounceTimer?.cancel();
                        _applyFilters();
                      },
                      child: const Text('Clear', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList() {
    return Consumer<OrderHistoryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.orders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  provider.error!,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _refreshData(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No orders found',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                if (provider.hasActiveFilters) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      provider.clearFilters();
                      _searchController.clear();
                      _debounceTimer?.cancel();
                      _applyFilters();
                    },
                    child: const Text('Clear filters to see all orders'),
                  ),
                ],
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _refreshData(),
          child: ListView.builder(
            itemCount: provider.orders.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final order = provider.orders[index];
              return _buildOrderCard(order);
            },
          ),
        );
      },
    );
  }

  Widget _buildOrderCard(OrderHistory order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToOrderDetails(order.id),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.orderNumber,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.customerName,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Formatters.currency(order.totalAmountValue),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.orderDate,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Order details
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${order.brickType} × ${order.quantityInt}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sales: ${order.salesExecutive}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildStatusChip(
                        order.paymentStatusDisplay,
                        _getPaymentStatusColor(order.paymentStatus),
                      ),
                      const SizedBox(height: 4),
                      _buildStatusChip(
                        order.deliveryStatusDisplay,
                        _getDeliveryStatusColor(order.deliveryStatus),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Payment info if relevant
              if (order.paymentStatus != 'no_payment' && 
                  order.outstandingAmountValue > 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Outstanding:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      Text(
                        Formatters.currency(order.outstandingAmountValue),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case 'pending':
      case 'no_payment':
        return Colors.grey;
      case 'partial':
        return Colors.orange;
      case 'paid':
        return Colors.blue;
      case 'approved':
        return Colors.green;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getDeliveryStatusColor(String status) {
    switch (status) {
      case 'pending':
      case 'not_assigned':
        return Colors.grey;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _navigateToOrderDetails(int orderId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => getIt<OrderHistoryProvider>(),
          child: OrderDetailsScreen(orderId: orderId),
        ),
      ),
    );
  }

  void _navigateToStatistics() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => getIt<OrderHistoryProvider>(),
          child: const OrderStatisticsScreen(),
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    final provider = context.read<OrderHistoryProvider>();
    await provider.fetchOrderHistory();
    // Only refresh statistics if they were previously loaded
    if (provider.statistics != null) {
      await provider.fetchOrderStatistics();
    }
  }

  Future<void> _applyFilters() async {
    await context.read<OrderHistoryProvider>().applyFilters();
  }

  /// Handle search input changes with debouncing
  void _onSearchChanged(String value) {
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    // If search is cleared, immediately apply
    if (value.isEmpty) {
      context.read<OrderHistoryProvider>().setSearchQuery(null);
      _applyFilters();
      return;
    }
    
    // If less than minimum length, don't search yet
    if (value.length < _minSearchLength) {
      context.read<OrderHistoryProvider>().setSearchQuery(null);
      return;
    }
    
    // Set up debounced search
    _debounceTimer = Timer(Duration(milliseconds: _searchDebounceMs), () {
      _performSearch(value);
    });
  }

  /// Perform the actual search
  void _performSearch(String query) {
    if (query.length >= _minSearchLength || query.isEmpty) {
      context.read<OrderHistoryProvider>().setSearchQuery(
        query.isEmpty ? null : query,
      );
      _applyFilters();
    }
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Orders'),
        content: const Text(
          'Export current filtered orders to Excel format?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _exportToExcel();
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToExcel() async {
    final provider = context.read<OrderHistoryProvider>();
    final result = await provider.exportOrdersToExcel();
    
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.successMessage ?? 'Export completed'),
          backgroundColor: Colors.green,
        ),
      );
      // Here you would typically trigger the actual file download
      // For now, we just show the success message
    } else if (provider.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}