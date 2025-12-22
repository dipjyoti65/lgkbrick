import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business/providers/payment_provider.dart';
import '../../data/models/delivery_challan.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/message_display.dart';
import '../widgets/empty_state_display.dart' as empty_state;
import '../../core/utils/formatters.dart';
import 'payment_form_screen.dart';

/// Screen to display all delivery challans with filtering and pagination
/// 
/// Shows challans in tabs: All, Pending, Completed with date range filtering
class AllChallansScreen extends StatefulWidget {
  const AllChallansScreen({super.key});

  @override
  State<AllChallansScreen> createState() => _AllChallansScreenState();
}

class _AllChallansScreenState extends State<AllChallansScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PaymentProvider _paymentProvider;
  
  // Filter state
  DateTimeRange? _selectedDateRange;
  int _currentPage = 1;
  static const int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _paymentProvider = context.read<PaymentProvider>();
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChallans();
    });
    
    // Listen to tab changes
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _currentPage = 1; // Reset to first page when switching tabs
        _loadChallans();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _currentStatus {
    switch (_tabController.index) {
      case 0:
        return 'all';
      case 1:
        return 'pending';
      case 2:
        return 'completed';
      default:
        return 'all';
    }
  }

  void _loadChallans() {
    final startDate = _selectedDateRange?.start;
    final endDate = _selectedDateRange?.end;
    
    _paymentProvider.fetchAllChallans(
      status: _currentStatus,
      startDate: startDate?.toIso8601String().split('T')[0],
      endDate: endDate?.toIso8601String().split('T')[0],
      page: _currentPage,
      perPage: _itemsPerPage,
    );
  }

  Future<void> _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.blue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
        _currentPage = 1; // Reset to first page
      });
      _loadChallans();
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDateRange = null;
      _currentPage = 1; // Reset to first page
    });
    _loadChallans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Challans'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadChallans,
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, paymentProvider, child) {
          return LoadingOverlay(
            isLoading: paymentProvider.isLoading,
            message: 'Loading challans...',
            child: Column(
              children: [
                // Filter Section
                _buildFilterSection(),
                
                // Error Message
                if (paymentProvider.error != null)
                  MessageDisplay.error(
                    paymentProvider.error!,
                    onDismiss: () => paymentProvider.clearError(),
                    margin: const EdgeInsets.all(16),
                  ),

                // Challans List
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildChallansList(paymentProvider.allChallans),
                      _buildChallansList(paymentProvider.pendingChallans),
                      _buildChallansList(paymentProvider.completedChallans),
                    ],
                  ),
                ),

                // Pagination
                if (paymentProvider.totalPages > 1)
                  _buildPaginationControls(paymentProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _selectedDateRange != null
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.date_range, color: Colors.blue.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${Formatters.date(_selectedDateRange!.start)} - ${Formatters.date(_selectedDateRange!.end)}',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.blue.shade700, size: 20),
                          onPressed: _clearDateFilter,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  )
                : Text(
                    'Showing today\'s challans',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _showDateRangePicker,
            icon: const Icon(Icons.filter_list, size: 20),
            label: const Text('Filter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallansList(List<DeliveryChallan> challans) {
    if (challans.isEmpty) {
      return empty_state.EmptyStateDisplay(
        icon: Icons.receipt_long_outlined,
        title: 'No Challans Found',
        subtitle: _selectedDateRange != null
            ? 'No challans found for the selected date range.'
            : 'No challans found for today.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: challans.length,
      itemBuilder: (context, index) {
        final challan = challans[index];
        return _buildChallanCard(challan);
      },
    );
  }

  Widget _buildChallanCard(DeliveryChallan challan) {
    final isPending = challan.deliveryStatus == 'pending';
    final hasPayment = challan.payment != null;
    final canProcessPayment = isPending && !hasPayment;
    final statusColor = hasPayment ? Colors.green : (isPending ? Colors.orange : Colors.blue);
    
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
                    color: statusColor.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    hasPayment ? 'Completed' : (isPending ? 'Pending' : 'Delivered'),
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor.shade700,
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
            _buildDetailRow('Date', challan.date),
            if (challan.deliveryDate != null)
              _buildDetailRow('Delivery Date', challan.deliveryDate!),

            // Action button for pending challans without payment
            if (canProcessPayment) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Pre-select this challan for payment processing
                    _paymentProvider.setSelectedChallan(challan);
                    
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider.value(
                          value: _paymentProvider,
                          child: const PaymentFormScreen(),
                        ),
                      ),
                    ).then((_) {
                      _loadChallans(); // Refresh after returning
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

  Widget _buildPaginationControls(PaymentProvider paymentProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Page $_currentPage of ${paymentProvider.totalPages}',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: _currentPage > 1
                    ? () {
                        setState(() {
                          _currentPage--;
                        });
                        _loadChallans();
                      }
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              IconButton(
                onPressed: _currentPage < paymentProvider.totalPages
                    ? () {
                        setState(() {
                          _currentPage++;
                        });
                        _loadChallans();
                      }
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }
}