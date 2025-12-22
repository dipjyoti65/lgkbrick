import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import '../../business/providers/order_history_provider.dart';
import '../../data/models/order_history.dart';
import '../../core/utils/formatters.dart';

/// Detailed order view screen
/// 
/// Displays comprehensive order information including customer details,
/// order specifics, sales information, logistics details, payment status,
/// and account approval information based on availability.
class OrderDetailsScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final provider = Provider.of<OrderHistoryProvider>(context, listen: false);
        provider.fetchOrderDetails(widget.orderId);
      } catch (e) {
        print('Provider not available in OrderDetailsScreen initState: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        elevation: 0,
        actions: [
          Consumer<OrderHistoryProvider>(
            builder: (context, provider, child) {
              if (provider.selectedOrder == null) return const SizedBox();
              
              return PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(value, provider.selectedOrder!),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'send_pdf',
                    child: Row(
                      children: [
                        Icon(Icons.picture_as_pdf, size: 20),
                        SizedBox(width: 8),
                        Text('Send PDF to Customer'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'call_customer',
                    child: Row(
                      children: [
                        Icon(Icons.phone, size: 20),
                        SizedBox(width: 8),
                        Text('Call Customer'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<OrderHistoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
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
                    onPressed: () => provider.fetchOrderDetails(widget.orderId),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final order = provider.selectedOrder;
          if (order == null) {
            return const Center(
              child: Text('Order not found'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderHeader(order),
                const SizedBox(height: 16),
                _buildCustomerDetails(order.customer),
                const SizedBox(height: 16),
                _buildOrderDetails(order.orderDetails),
                const SizedBox(height: 16),
                _buildSalesDetails(order.salesDetails),
                if (order.logisticsDetails != null) ...[
                  const SizedBox(height: 16),
                  _buildLogisticsDetails(order.logisticsDetails!),
                ],
                if (order.paymentDetails != null) ...[
                  const SizedBox(height: 16),
                  _buildPaymentDetails(order.paymentDetails!),
                ],
                if (order.accountDetails != null) ...[
                  const SizedBox(height: 16),
                  _buildAccountDetails(order.accountDetails!),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderHeader(OrderDetails order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderNumber,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Order Date: ${_formatDateTime(order.orderDate)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                _buildStatusChip(order.status, _getOrderStatusColor(order.status)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerDetails(CustomerDetails customer) {
    return _buildSection(
      title: 'Customer Information',
      icon: Icons.person,
      child: Column(
        children: [
          _buildDetailRow('Name', customer.name),
          _buildDetailRow('Phone', customer.phone, 
            trailing: IconButton(
              icon: const Icon(Icons.phone, size: 20),
              onPressed: () => _makePhoneCall(customer.phone),
            ),
          ),
          _buildDetailRow('Address', customer.address),
        ],
      ),
    );
  }

  Widget _buildOrderDetails(OrderDetailsInfo orderDetails) {
    return _buildSection(
      title: 'Order Information',
      icon: Icons.shopping_cart,
      child: Column(
        children: [
          _buildDetailRow('Brick Type', orderDetails.brickType.name),
          if (orderDetails.brickType.description?.isNotEmpty == true)
            _buildDetailRow('Description', orderDetails.brickType.description!),
          if (orderDetails.brickType.category?.isNotEmpty == true)
            _buildDetailRow('Category', orderDetails.brickType.category!),
          _buildDetailRow('Quantity', '${orderDetails.quantityInt} ${orderDetails.brickType.unit ?? 'units'}'),
          _buildDetailRow('Price per Unit', Formatters.currency(double.tryParse(orderDetails.pricePerUnit) ?? 0)),
          _buildDetailRow('Total Amount', Formatters.currency(double.tryParse(orderDetails.totalAmount) ?? 0),
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          if (orderDetails.specialInstructions?.isNotEmpty == true)
            _buildDetailRow('Special Instructions', orderDetails.specialInstructions!),
        ],
      ),
    );
  }

  Widget _buildSalesDetails(SalesDetails salesDetails) {
    return _buildSection(
      title: 'Sales Executive',
      icon: Icons.person_outline,
      child: Column(
        children: [
          _buildDetailRow('Name', salesDetails.executiveName),
          _buildDetailRow('Email', salesDetails.executiveEmail),
          _buildDetailRow('Phone', salesDetails.executivePhone,
            trailing: IconButton(
              icon: const Icon(Icons.phone, size: 20),
              onPressed: () => _makePhoneCall(salesDetails.executivePhone),
            ),
          ),
          _buildDetailRow('Department', salesDetails.department),
          _buildDetailRow('Role', salesDetails.role),
        ],
      ),
    );
  }

  Widget _buildLogisticsDetails(LogisticsDetails logisticsDetails) {
    return _buildSection(
      title: 'Logistics Information',
      icon: Icons.local_shipping,
      child: Column(
        children: [
          _buildDetailRow('Challan Number', logisticsDetails.challanNumber),
          _buildDetailRow('Delivery Status', logisticsDetails.deliveryStatus,
            trailing: _buildStatusChip(logisticsDetails.deliveryStatus, _getDeliveryStatusColor(logisticsDetails.deliveryStatus))),
          if (logisticsDetails.deliveryDate != null)
            _buildDetailRow('Delivery Date', logisticsDetails.deliveryDate!),
          if (logisticsDetails.deliveryTime != null)
            _buildDetailRow('Delivery Time', logisticsDetails.deliveryTime!),
          if (logisticsDetails.driverName != null)
            _buildDetailRow('Driver Name', logisticsDetails.driverName!),
          if (logisticsDetails.vehicleNumber != null)
            _buildDetailRow('Vehicle Number', logisticsDetails.vehicleNumber!),
          if (logisticsDetails.vehicleType != null)
            _buildDetailRow('Vehicle Type', logisticsDetails.vehicleType!),
          if (logisticsDetails.remarks?.isNotEmpty == true)
            _buildDetailRow('Remarks', logisticsDetails.remarks!),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails(PaymentDetails paymentDetails) {
    final totalAmount = double.tryParse(paymentDetails.totalAmount) ?? 0;
    final amountReceived = double.tryParse(paymentDetails.amountReceived) ?? 0;
    final remainingAmount = double.tryParse(paymentDetails.remainingAmount) ?? 0;

    return _buildSection(
      title: 'Payment Information',
      icon: Icons.payment,
      child: Column(
        children: [
          _buildDetailRow('Payment Status', paymentDetails.paymentStatus,
            trailing: _buildStatusChip(paymentDetails.paymentStatus, _getPaymentStatusColor(paymentDetails.paymentStatus))),
          _buildDetailRow('Total Amount', Formatters.currency(totalAmount)),
          _buildDetailRow('Amount Received', Formatters.currency(amountReceived),
            style: TextStyle(color: amountReceived > 0 ? Colors.green : Colors.grey)),
          if (remainingAmount > 0)
            _buildDetailRow('Remaining Amount', Formatters.currency(remainingAmount),
              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          if (paymentDetails.paymentDate != null)
            _buildDetailRow('Payment Date', paymentDetails.paymentDate!),
          if (paymentDetails.paymentMethod != null)
            _buildDetailRow('Payment Method', _formatPaymentMethod(paymentDetails.paymentMethod!)),
          if (paymentDetails.referenceNumber != null)
            _buildDetailRow('Reference Number', paymentDetails.referenceNumber!),
          if (paymentDetails.remarks?.isNotEmpty == true)
            _buildDetailRow('Remarks', paymentDetails.remarks!),
        ],
      ),
    );
  }

  Widget _buildAccountDetails(AccountDetails accountDetails) {
    return _buildSection(
      title: 'Account Approval',
      icon: Icons.verified,
      child: Column(
        children: [
          _buildDetailRow('Approved By', accountDetails.approvedBy),
          _buildDetailRow('Approver Email', accountDetails.approvedByEmail),
          _buildDetailRow('Approved At', _formatDateTime(accountDetails.approvedAt)),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Payment has been approved and finalized',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {TextStyle? style, Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: style ?? const TextStyle(fontSize: 14),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getOrderStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return Colors.blue;
      case 'assigned':
        return Colors.orange;
      case 'delivered':
        return Colors.green;
      case 'paid':
        return Colors.teal;
      case 'complete':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
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
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(String dateTime) {
    try {
      final dt = DateTime.parse(dateTime);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime;
    }
  }

  String _formatPaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'Cash';
      case 'cheque':
        return 'Cheque';
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'upi':
        return 'UPI';
      default:
        return method;
    }
  }

  void _handleMenuAction(String action, OrderDetails order) {
    switch (action) {
      case 'send_pdf':
        _sendPdfToCustomer(order);
        break;
      case 'call_customer':
        _makePhoneCall(order.customer.phone);
        break;
    }
  }

  Future<void> _sendPdfToCustomer(OrderDetails order) async {
    final provider = context.read<OrderHistoryProvider>();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Generating PDF...'),
          ],
        ),
      ),
    );

    final result = await provider.generateOrderPdf(order.id);
    
    if (mounted) {
      Navigator.pop(context); // Close loading dialog
      
      if (result != null) {
        // Show sharing options
        _showSharingOptions(order, result);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to generate PDF'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSharingOptions(OrderDetails order, Map<String, dynamic> pdfData) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              'Share Order PDF',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Order: ${order.orderNumber}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            
            // Sharing options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSharingOption(
                  icon: Icons.share,
                  label: 'Share',
                  color: Colors.blue,
                  onTap: () => _shareViaNativeShare(order, pdfData),
                ),
                _buildSharingOption(
                  icon: Icons.message,
                  label: 'WhatsApp',
                  color: Colors.green,
                  onTap: () => _shareViaWhatsApp(order, pdfData),
                ),
                _buildSharingOption(
                  icon: Icons.email,
                  label: 'Email',
                  color: Colors.red,
                  onTap: () => _shareViaEmail(order, pdfData),
                ),
                _buildSharingOption(
                  icon: Icons.more_horiz,
                  label: 'More',
                  color: Colors.grey,
                  onTap: () => _shareViaNativeShare(order, pdfData),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSharingOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareViaNativeShare(OrderDetails order, Map<String, dynamic> pdfData) async {
    Navigator.pop(context); // Close bottom sheet
    
    try {
      // Create a temporary PDF file
      final file = await _createTempPdfFile(order, pdfData);
      
      // Share using the native share dialog
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Order Details - ${order.orderNumber}\nCustomer: ${order.customer.name}',
        subject: 'Order PDF - ${order.orderNumber}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareViaWhatsApp(OrderDetails order, Map<String, dynamic> pdfData) async {
    Navigator.pop(context); // Close bottom sheet
    
    try {
      // Create a temporary PDF file
      final file = await _createTempPdfFile(order, pdfData);
      
      // Try to share via WhatsApp specifically
      final whatsappUrl = 'whatsapp://send?text=${Uri.encodeComponent('Order Details - ${order.orderNumber}\nCustomer: ${order.customer.name}')}';
      
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        // If WhatsApp is available, use native share with WhatsApp preference
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Order Details - ${order.orderNumber}\nCustomer: ${order.customer.name}',
          subject: 'Order PDF - ${order.orderNumber}',
        );
      } else {
        // Fallback to regular share
        await _shareViaNativeShare(order, pdfData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('WhatsApp not installed. Using default share.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share via WhatsApp: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareViaEmail(OrderDetails order, Map<String, dynamic> pdfData) async {
    Navigator.pop(context); // Close bottom sheet
    
    try {
      // Create a temporary PDF file
      final file = await _createTempPdfFile(order, pdfData);
      
      // Create email URL with attachment
      final emailUrl = 'mailto:${order.customer.name.replaceAll(' ', '').toLowerCase()}@example.com'
          '?subject=${Uri.encodeComponent('Order PDF - ${order.orderNumber}')}'
          '&body=${Uri.encodeComponent('Please find attached the order details for ${order.orderNumber}.\n\nCustomer: ${order.customer.name}\nOrder Date: ${order.orderDate}\nTotal Amount: ${Formatters.currency(double.tryParse(order.orderDetails.totalAmount) ?? 0)}')}';
      
      if (await canLaunchUrl(Uri.parse(emailUrl))) {
        // Launch email app, then share file
        await launchUrl(Uri.parse(emailUrl));
        
        // Also trigger native share for the PDF
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Order Details - ${order.orderNumber}',
          subject: 'Order PDF - ${order.orderNumber}',
        );
      } else {
        // Fallback to regular share
        await _shareViaNativeShare(order, pdfData);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share via email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<File> _createTempPdfFile(OrderDetails order, Map<String, dynamic> pdfData) async {
    // Get temporary directory
    final tempDir = await getTemporaryDirectory();
    final fileName = 'order_${order.orderNumber}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${tempDir.path}/$fileName');
    
    // For now, create a simple text file as placeholder
    // In a real implementation, you would use the PDF data from the API
    final pdfContent = '''
Order Details - ${order.orderNumber}

Customer Information:
Name: ${order.customer.name}
Phone: ${order.customer.phone}
Address: ${order.customer.address}

Order Information:
Order Number: ${order.orderNumber}
Order Date: ${order.orderDate}
Status: ${order.status}

Product Details:
Brick Type: ${order.orderDetails.brickType.name}
Quantity: ${order.orderDetails.quantityInt}
Price per Unit: ${Formatters.currency(double.tryParse(order.orderDetails.pricePerUnit) ?? 0)}
Total Amount: ${Formatters.currency(double.tryParse(order.orderDetails.totalAmount) ?? 0)}

Sales Executive: ${order.salesDetails.executiveName}
Department: ${order.salesDetails.department}

Generated on: ${DateTime.now().toString()}
    ''';
    
    // Write content to file (in real implementation, this would be PDF binary data)
    await file.writeAsString(pdfContent);
    
    return file;
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not launch phone dialer'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}