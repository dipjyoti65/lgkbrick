import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business/providers/requisition_provider.dart';
import '../../core/di/service_locator.dart';
import '../../data/models/requisition.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/message_display.dart';
import '../widgets/empty_state_display.dart' as empty_state;

/// Screen showing pending orders for logistics users
/// 
/// Displays submitted requisitions that are awaiting delivery challan creation.
class PendingOrdersScreen extends StatefulWidget {
  const PendingOrdersScreen({super.key});

  @override
  State<PendingOrdersScreen> createState() => _PendingOrdersScreenState();
}

class _PendingOrdersScreenState extends State<PendingOrdersScreen> {
  late RequisitionProvider _requisitionProvider;

  @override
  void initState() {
    super.initState();
    _requisitionProvider = getIt<RequisitionProvider>();
    _loadPendingOrders();
  }

  Future<void> _loadPendingOrders() async {
    // Fetch requisitions with 'submitted' status
    await _requisitionProvider.setStatusFilter('submitted');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Orders'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingOrders,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: ChangeNotifierProvider.value(
        value: _requisitionProvider,
        child: Consumer<RequisitionProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.requisitions.isEmpty) {
              return const Center(
                child: LoadingIndicator(
                  message: 'Loading pending orders...',
                  size: 32,
                ),
              );
            }

            if (provider.error != null && provider.requisitions.isEmpty) {
              return Center(
                child: MessageDisplay.error(
                  provider.error!,
                  onRetry: _loadPendingOrders,
                ),
              );
            }

            final pendingOrders = provider.requisitions
                .where((r) => r.status == 'submitted')
                .toList();

            if (pendingOrders.isEmpty) {
              return const empty_state.EmptyStateDisplay(
                icon: Icons.pending_actions,
                title: 'No Pending Orders',
                subtitle: 'All orders have been processed or no new orders are available for delivery.',
              );
            }

            return RefreshIndicator(
              onRefresh: _loadPendingOrders,
              child: LoadingOverlay(
                isLoading: provider.isLoading,
                message: 'Refreshing...',
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pendingOrders.length,
                  itemBuilder: (context, index) {
                    final order = pendingOrders[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PendingOrderCard(
                        requisition: order,
                        onTap: () => _showOrderDetails(order),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showOrderDetails(Requisition requisition) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderDetailsBottomSheet(requisition: requisition),
    );
  }

  @override
  void dispose() {
    _requisitionProvider.clearFilters();
    super.dispose();
  }
}

/// Card widget for displaying pending orders
class PendingOrderCard extends StatelessWidget {
  final Requisition requisition;
  final VoidCallback onTap;

  const PendingOrderCard({
    super.key,
    required this.requisition,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with order number and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    requisition.orderNumber,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'PENDING',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Date
              Text(
                'Date: ${requisition.date}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Order details
              Row(
                children: [
                  Icon(
                    Icons.construction,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${requisition.brickType?.name ?? 'N/A'} - ${requisition.quantity} ${requisition.brickType?.unit ?? ''}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Customer details
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      requisition.customerName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Bottom row with amount and arrow
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹${requisition.totalAmount}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet to show order details
class OrderDetailsBottomSheet extends StatelessWidget {
  final Requisition requisition;

  const OrderDetailsBottomSheet({
    super.key,
    required this.requisition,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Order Details',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Order Number', requisition.orderNumber),
                  _buildDetailRow('Date', requisition.date),
                  _buildDetailRow('Status', 'PENDING DELIVERY'),
                  _buildDetailRow('Brick Type', requisition.brickType?.name ?? 'N/A'),
                  _buildDetailRow('Quantity', '${requisition.quantity} ${requisition.brickType?.unit ?? ''}'),
                  _buildDetailRow('Price per Unit', '₹${requisition.pricePerUnit}'),
                  if (requisition.enteredPrice != null)
                    _buildDetailRow('Entered Price', '₹${requisition.enteredPrice}'),
                  _buildDetailRow('Total Amount', '₹${requisition.totalAmount}'),
                  const SizedBox(height: 16),
                  Text(
                    'Customer Details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow('Name', requisition.customerName),
                  _buildDetailRow('Phone', requisition.customerPhone),
                  _buildDetailRow('Address', requisition.customerAddress),
                  _buildDetailRow('Location', requisition.customerLocation ?? 'N/A'),
                ],
              ),
            ),
          ),
          
          // Action button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showCreateChallanDialog(context, requisition);
                },
                icon: const Icon(Icons.local_shipping),
                label: const Text('Create Delivery Challan'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateChallanDialog(BuildContext context, Requisition requisition) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Delivery Challan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order: ${requisition.orderNumber}'),
            Text('Customer: ${requisition.customerName}'),
            Text('Quantity: ${requisition.quantity} ${requisition.brickType?.unit ?? ''}'),
            Text('Amount: ₹${requisition.totalAmount}'),
            const SizedBox(height: 16),
            const Text(
              'This will create a delivery challan and mark the order as assigned for delivery.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Delivery challan created for ${requisition.orderNumber}'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Create Challan'),
          ),
        ],
      ),
    );
  }
}