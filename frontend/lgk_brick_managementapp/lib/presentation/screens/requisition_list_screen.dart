import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business/providers/requisition_provider.dart';
import '../../core/di/service_locator.dart';
import '../../data/models/requisition.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/message_display.dart';
import '../widgets/requisition_card.dart';
import '../widgets/empty_state_display.dart' as empty_state;

/// Requisition list screen that can display different types of requisition lists
/// 
/// Supports different modes:
/// - all: All requisitions for the current user
/// - pending: Only submitted/pending requisitions
/// - history: All completed/processed requisitions
class RequisitionListScreen extends StatefulWidget {
  final String title;
  final RequisitionListMode mode;
  final String? statusFilter;

  const RequisitionListScreen({
    super.key,
    required this.title,
    required this.mode,
    this.statusFilter,
  });

  @override
  State<RequisitionListScreen> createState() => _RequisitionListScreenState();
}

class _RequisitionListScreenState extends State<RequisitionListScreen> {
  late RequisitionProvider _requisitionProvider;

  @override
  void initState() {
    super.initState();
    _requisitionProvider = getIt<RequisitionProvider>();
    _loadRequisitions();
  }

  Future<void> _loadRequisitions() async {
    switch (widget.mode) {
      case RequisitionListMode.all:
        await _requisitionProvider.fetchRequisitions();
        break;
      case RequisitionListMode.pending:
        await _requisitionProvider.setStatusFilter('submitted');
        break;
      case RequisitionListMode.history:
        // Fetch all except submitted (assigned, delivered, paid, complete)
        await _requisitionProvider.fetchRequisitions();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRequisitions,
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
                  message: 'Loading requisitions...',
                  size: 32,
                ),
              );
            }

            if (provider.error != null && provider.requisitions.isEmpty) {
              return Center(
                child: MessageDisplay.error(
                  provider.error!,
                  onRetry: _loadRequisitions,
                ),
              );
            }

            final filteredRequisitions = _getFilteredRequisitions(provider.requisitions);

            if (filteredRequisitions.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: _loadRequisitions,
              child: LoadingOverlay(
                isLoading: provider.isLoading,
                message: 'Refreshing...',
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredRequisitions.length,
                  itemBuilder: (context, index) {
                    final requisition = filteredRequisitions[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: RequisitionCard(
                        requisition: requisition,
                        onTap: () => _showRequisitionDetails(requisition),
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

  List<Requisition> _getFilteredRequisitions(List<Requisition> requisitions) {
    switch (widget.mode) {
      case RequisitionListMode.all:
        return requisitions;
      case RequisitionListMode.pending:
        return requisitions.where((r) => r.status == 'submitted').toList();
      case RequisitionListMode.history:
        return requisitions.where((r) => r.status != 'submitted').toList();
    }
  }

  Widget _buildEmptyState() {
    String message;
    String description;
    IconData icon;

    switch (widget.mode) {
      case RequisitionListMode.all:
        message = 'No Requisitions';
        description = 'You haven\'t created any requisitions yet. Tap the "Create Requisition" button to get started.';
        icon = Icons.list_alt;
        break;
      case RequisitionListMode.pending:
        message = 'No Pending Orders';
        description = 'All your orders have been processed. Create a new requisition to see pending orders here.';
        icon = Icons.pending_actions;
        break;
      case RequisitionListMode.history:
        message = 'No Order History';
        description = 'You don\'t have any processed orders yet. Orders will appear here once they are assigned or completed.';
        icon = Icons.history;
        break;
    }

    return empty_state.EmptyStateDisplay(
      icon: icon,
      title: message,
      subtitle: description,
      actionText: widget.mode == RequisitionListMode.all ? 'Create Requisition' : null,
      onActionPressed: widget.mode == RequisitionListMode.all 
          ? () => Navigator.of(context).pop() 
          : null,
    );
  }

  void _showRequisitionDetails(Requisition requisition) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RequisitionDetailsBottomSheet(requisition: requisition),
    );
  }

  @override
  void dispose() {
    // Clear any filters when leaving the screen
    _requisitionProvider.clearFilters();
    super.dispose();
  }
}

/// Enum for different requisition list modes
enum RequisitionListMode {
  all,
  pending,
  history,
}

/// Bottom sheet to show requisition details
class RequisitionDetailsBottomSheet extends StatelessWidget {
  final Requisition requisition;

  const RequisitionDetailsBottomSheet({
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
                  _buildDetailRow('Status', requisition.status.toUpperCase()),
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
}