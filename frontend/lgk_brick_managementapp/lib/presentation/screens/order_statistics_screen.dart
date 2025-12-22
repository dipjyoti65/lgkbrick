import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business/providers/order_history_provider.dart';
import '../../core/utils/formatters.dart';

/// Order Statistics Screen
/// 
/// Displays comprehensive order statistics including total orders,
/// payment status breakdown, and financial summaries.
class OrderStatisticsScreen extends StatefulWidget {
  const OrderStatisticsScreen({super.key});

  @override
  State<OrderStatisticsScreen> createState() => _OrderStatisticsScreenState();
}

class _OrderStatisticsScreenState extends State<OrderStatisticsScreen> {
  @override
  void initState() {
    super.initState();
    // Use a safer approach to access the provider after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final provider = Provider.of<OrderHistoryProvider>(context, listen: false);
        provider.fetchOrderStatistics();
      } catch (e) {
        // If provider is not available, we'll handle it in the build method
        print('Provider not available in initState: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Statistics'),
        elevation: 0,
      ),
      body: Consumer<OrderHistoryProvider>(
        builder: (context, provider, child) {
          // Show loading if statistics are being fetched
          if (provider.isLoading && provider.statistics == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Show error if there's an error and no statistics
          if (provider.error != null && provider.statistics == null) {
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
                    onPressed: () {
                      final providerInstance = Provider.of<OrderHistoryProvider>(context, listen: false);
                      providerInstance.fetchOrderStatistics();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Show message if no statistics available
          if (provider.statistics == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No statistics available',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      final providerInstance = Provider.of<OrderHistoryProvider>(context, listen: false);
                      providerInstance.fetchOrderStatistics();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Load Statistics'),
                  ),
                ],
              ),
            );
          }

          final stats = provider.statistics!;

          return RefreshIndicator(
            onRefresh: () => provider.fetchOrderStatistics(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Overview Card
                _buildOverviewCard(context, stats),
                
                const SizedBox(height: 16),
                
                // Payment Status Breakdown
                _buildPaymentStatusCard(context, stats),
                
                const SizedBox(height: 16),
                
                // Financial Summary
                _buildFinancialSummaryCard(context, stats),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context, stats) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Main metrics
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    context,
                    'Total Orders',
                    stats.totalOrders.toString(),
                    Icons.shopping_cart,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricItem(
                    context,
                    'Total Value',
                    Formatters.currency(double.tryParse(stats.totalValue) ?? 0),
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusCard(BuildContext context, stats) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.payment,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Payment Status Breakdown',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Payment status items
            _buildStatusItem(
              'Pending Payments',
              stats.pendingPayments.toString(),
              Colors.grey,
              Icons.pending,
            ),
            const SizedBox(height: 12),
            _buildStatusItem(
              'Partial Payments',
              stats.partialPayments.toString(),
              Colors.orange,
              Icons.hourglass_bottom,
            ),
            const SizedBox(height: 12),
            _buildStatusItem(
              'Paid Orders',
              stats.paidOrders.toString(),
              Colors.blue,
              Icons.check_circle,
            ),
            const SizedBox(height: 12),
            _buildStatusItem(
              'Approved Orders',
              stats.approvedOrders.toString(),
              Colors.green,
              Icons.verified,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummaryCard(BuildContext context, stats) {
    final outstandingAmount = double.tryParse(stats.outstandingAmount) ?? 0;
    final totalReceived = double.tryParse(stats.totalReceived) ?? 0;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Financial Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Total Received
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.arrow_downward, color: Colors.green.shade700, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Total Received',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    Formatters.currency(totalReceived),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Outstanding Amount
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.arrow_upward, color: Colors.orange.shade700, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Outstanding Amount',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    Formatters.currency(outstandingAmount),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
