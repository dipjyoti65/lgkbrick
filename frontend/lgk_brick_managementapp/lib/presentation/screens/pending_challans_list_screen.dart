import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business/providers/payment_provider.dart';
import '../../data/models/delivery_challan.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/message_display.dart';
import '../widgets/empty_state_display.dart' hide EmptyStateDisplay;
import '../../core/utils/formatters.dart';
import 'payment_form_screen.dart';

/// Screen to display pending challans awaiting payment
/// 
/// Shows a list of delivered challans that haven't been paid yet,
/// allowing accounts users to view details and process payments.
class PendingChallansListScreen extends StatefulWidget {
  const PendingChallansListScreen({super.key});

  @override
  State<PendingChallansListScreen> createState() => _PendingChallansListScreenState();
}

class _PendingChallansListScreenState extends State<PendingChallansListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch pending challans when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final paymentProvider = context.read<PaymentProvider>();
      paymentProvider.fetchPendingChallans();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Challans'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final paymentProvider = context.read<PaymentProvider>();
              paymentProvider.fetchPendingChallans();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, paymentProvider, child) {
          return LoadingOverlay(
            isLoading: paymentProvider.isLoading,
            message: 'Loading pending challans...',
            child: Column(
              children: [
                // Header with count
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    border: Border(
                      bottom: BorderSide(color: Colors.orange.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.pending_actions, color: Colors.orange.shade700),
                      const SizedBox(width: 12),
                      Text(
                        '${paymentProvider.pendingChallans.length} Pending Challans',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                // Error Message
                if (paymentProvider.error != null)
                  MessageDisplay.error(
                    paymentProvider.error!,
                    onDismiss: () => paymentProvider.clearError(),
                    margin: const EdgeInsets.all(16),
                  ),

                // Challans List
                Expanded(
                  child: paymentProvider.pendingChallans.isEmpty
                      ? const EmptyStateDisplay(
                          icon: Icons.payment_outlined,
                          title: 'No Pending Challans',
                          subtitle: 'All delivered challans have been processed for payment.',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: paymentProvider.pendingChallans.length,
                          itemBuilder: (context, index) {
                            final challan = paymentProvider.pendingChallans[index];
                            return _buildChallanCard(challan);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChallanCard(DeliveryChallan challan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with challan number and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  challan.challanNumber,
                  style: const TextStyle(
                    fontSize: 18,
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
                    'Pending Payment',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Order details
            _buildDetailRow('Order Number', challan.requisition?.orderNumber ?? 'N/A'),
            _buildDetailRow('Brick Type', challan.requisition?.brickType?.name ?? 'N/A'),
            _buildDetailRow('Quantity', '${challan.requisition?.quantity ?? 0} ${challan.requisition?.brickType?.unit ?? ''}'),
            _buildDetailRow('Customer', challan.requisition?.customerName ?? 'N/A'),
            _buildDetailRow('Amount', '₹${challan.requisition?.totalAmount ?? 0}'),
            _buildDetailRow('Delivery Date', challan.deliveryDate ?? 'N/A'),

            const SizedBox(height: 16),

            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to payment form with this challan pre-selected
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider.value(
                        value: context.read<PaymentProvider>(),
                        child: const PaymentFormScreen(),
                      ),
                    ),
                  ).then((_) {
                    // Refresh the list when returning from payment form
                    context.read<PaymentProvider>().fetchPendingChallans();
                  });
                },
                icon: const Icon(Icons.payment),
                label: const Text('Process Payment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}