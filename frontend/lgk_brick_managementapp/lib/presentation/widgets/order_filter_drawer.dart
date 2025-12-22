import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business/providers/order_history_provider.dart';

/// Filter drawer for Order History screen
/// 
/// Provides filtering options including payment status, order status,
/// date range selection, and filter management.
class OrderFilterDrawer extends StatefulWidget {
  const OrderFilterDrawer({super.key});

  @override
  State<OrderFilterDrawer> createState() => _OrderFilterDrawerState();
}

class _OrderFilterDrawerState extends State<OrderFilterDrawer> {
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter Orders',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Customize your order view',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Filter content
          Expanded(
            child: Consumer<OrderHistoryProvider>(
              builder: (context, provider, child) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Payment Status Filter
                    _buildFilterSection(
                      title: 'Payment Status',
                      icon: Icons.payment,
                      child: _buildPaymentStatusFilter(provider),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Order Status Filter
                    _buildFilterSection(
                      title: 'Order Status',
                      icon: Icons.assignment,
                      child: _buildOrderStatusFilter(provider),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Date Range Filter
                    _buildFilterSection(
                      title: 'Date Range',
                      icon: Icons.date_range,
                      child: _buildDateRangeFilter(provider),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Action buttons
                    _buildActionButtons(provider),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildPaymentStatusFilter(OrderHistoryProvider provider) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: provider.paymentStatusOptions.map((option) {
          final isSelected = provider.paymentStatusFilter == option['value'] ||
              (provider.paymentStatusFilter == null && option['value'] == '');
          
          return InkWell(
            onTap: () {
              final value = option['value'] == '' ? null : option['value'];
              provider.setPaymentStatusFilter(value);
              // Auto-apply filters when selection changes
              provider.applyFilters();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : null,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade200,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option['label']!,
                      style: TextStyle(
                        color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOrderStatusFilter(OrderHistoryProvider provider) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: provider.orderStatusOptions.map((option) {
          final isSelected = provider.orderStatusFilter == option['value'] ||
              (provider.orderStatusFilter == null && option['value'] == '');
          
          return InkWell(
            onTap: () {
              final value = option['value'] == '' ? null : option['value'];
              provider.setOrderStatusFilter(value);
              // Auto-apply filters when selection changes
              provider.applyFilters();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : null,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade200,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option['label']!,
                      style: TextStyle(
                        color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateRangeFilter(OrderHistoryProvider provider) {
    return Column(
      children: [
        // From Date
        InkWell(
          onTap: () => _selectFromDate(provider),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'From Date',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        provider.fromDate ?? 'Select start date',
                        style: TextStyle(
                          fontSize: 16,
                          color: provider.fromDate != null ? Colors.black87 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (provider.fromDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      _fromDate = null;
                      provider.setDateRangeFilter(null, provider.toDate);
                      // Auto-apply filters when date is cleared
                      provider.applyFilters();
                    },
                  ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // To Date
        InkWell(
          onTap: () => _selectToDate(provider),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'To Date',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        provider.toDate ?? 'Select end date',
                        style: TextStyle(
                          fontSize: 16,
                          color: provider.toDate != null ? Colors.black87 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (provider.toDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      _toDate = null;
                      provider.setDateRangeFilter(provider.fromDate, null);
                      // Auto-apply filters when date is cleared
                      provider.applyFilters();
                    },
                  ),
              ],
            ),
          ),
        ),
        
        // Quick date range buttons
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            _buildQuickDateButton('Today', provider, () {
              final today = DateTime.now();
              final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
              provider.setDateRangeFilter(todayStr, todayStr);
              provider.applyFilters();
            }),
            _buildQuickDateButton('This Week', provider, () {
              final now = DateTime.now();
              final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
              final endOfWeek = startOfWeek.add(const Duration(days: 6));
              provider.setDateRangeFilter(
                '${startOfWeek.year}-${startOfWeek.month.toString().padLeft(2, '0')}-${startOfWeek.day.toString().padLeft(2, '0')}',
                '${endOfWeek.year}-${endOfWeek.month.toString().padLeft(2, '0')}-${endOfWeek.day.toString().padLeft(2, '0')}',
              );
              provider.applyFilters();
            }),
            _buildQuickDateButton('This Month', provider, () {
              final now = DateTime.now();
              final startOfMonth = DateTime(now.year, now.month, 1);
              final endOfMonth = DateTime(now.year, now.month + 1, 0);
              provider.setDateRangeFilter(
                '${startOfMonth.year}-${startOfMonth.month.toString().padLeft(2, '0')}-${startOfMonth.day.toString().padLeft(2, '0')}',
                '${endOfMonth.year}-${endOfMonth.month.toString().padLeft(2, '0')}-${endOfMonth.day.toString().padLeft(2, '0')}',
              );
              provider.applyFilters();
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickDateButton(String label, OrderHistoryProvider provider, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildActionButtons(OrderHistoryProvider provider) {
    return Column(
      children: [
        // Apply Filters button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: provider.isLoading ? null : () {
              provider.applyFilters();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.filter_list),
            label: const Text('Apply Filters'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Clear Filters button
        if (provider.hasActiveFilters)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                provider.clearFilters();
                _fromDate = null;
                _toDate = null;
                provider.applyFilters();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear All Filters'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _selectFromDate(OrderHistoryProvider provider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      _fromDate = picked;
      final dateStr = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      provider.setDateRangeFilter(dateStr, provider.toDate);
      // Auto-apply filters when date is selected
      provider.applyFilters();
    }
  }

  Future<void> _selectToDate(OrderHistoryProvider provider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? DateTime.now(),
      firstDate: _fromDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      _toDate = picked;
      final dateStr = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      provider.setDateRangeFilter(provider.fromDate, dateStr);
      // Auto-apply filters when date is selected
      provider.applyFilters();
    }
  }
}