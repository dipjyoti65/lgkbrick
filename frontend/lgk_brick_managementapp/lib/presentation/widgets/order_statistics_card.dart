import 'package:flutter/material.dart';
import '../../data/models/order_history.dart';
import '../../core/utils/formatters.dart';

/// Statistics card widget for Order History screen
/// 
/// Displays key metrics including total orders, payment status breakdown,
/// and financial summaries in an expandable format.
class OrderStatisticsCard extends StatefulWidget {
  final OrderStatistics statistics;

  const OrderStatisticsCard({
    super.key,
    required this.statistics,
  });

  @override
  State<OrderStatisticsCard> createState() => _OrderStatisticsCardState();
}

class _OrderStatisticsCardState extends State<OrderStatisticsCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          // Header - Always visible
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.analytics,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Order Statistics',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Quick summary when collapsed
                  if (!_isExpanded) ...[
                    Text(
                      '${widget.statistics.totalOrders} orders',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          
          // Expandable content
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main metrics row
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricItem(
                          'Total Orders',
                          widget.statistics.totalOrders.toString(),
                          Icons.shopping_cart,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricItem(
                          'Total Value',
                          Formatters.currency(double.tryParse(widget.statistics.totalValue) ?? 0),
                          Icons.attach_money,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Payment status breakdown
                  _buildPaymentStatusBreakdown(),
                  
                  const SizedBox(height: 16),
                  
                  // Financial summary
                  _buildFinancialSummary(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Status Breakdown',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatusChip(
                'Pending',
                widget.statistics.pendingPayments.toString(),
                Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatusChip(
                'Partial',
                widget.statistics.partialPayments.toString(),
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatusChip(
                'Paid',
                widget.statistics.paidOrders.toString(),
                Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatusChip(
                'Approved',
                widget.statistics.approvedOrders.toString(),
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
          Text(
            count,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary() {
    final outstandingAmount = double.tryParse(widget.statistics.outstandingAmount) ?? 0;
    final totalReceived = double.tryParse(widget.statistics.totalReceived) ?? 0;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Received:',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.green,
                ),
              ),
              Text(
                Formatters.currency(totalReceived),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Outstanding:',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.orange,
                ),
              ),
              Text(
                Formatters.currency(outstandingAmount),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}