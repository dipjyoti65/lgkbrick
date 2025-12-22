import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../business/providers/payment_provider.dart';
import '../../data/models/delivery_challan.dart';

/// Payment processing form screen
/// 
/// Provides a form for accounts users to process payments with
/// pending challan selection, auto-fill functionality, and payment details input.
class PaymentFormScreen extends StatefulWidget {
  const PaymentFormScreen({super.key});

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

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
        title: const Text('Process Payment'),
        elevation: 0,
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, paymentProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Pending Challans Dropdown
                  _buildPendingChallansDropdown(paymentProvider),
                  const SizedBox(height: 24),

                  // Auto-filled Challan Details Section
                  if (paymentProvider.selectedChallan != null) ...[
                    _buildChallanDetailsCard(paymentProvider),
                    const SizedBox(height: 24),
                  ],

                  // Payment Details Section
                  Text(
                    'Payment Details',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  // Amount Received
                  _buildAmountReceivedField(paymentProvider),
                  const SizedBox(height: 16),

                  // Payment Method (Optional)
                  _buildPaymentMethodField(paymentProvider),
                  const SizedBox(height: 16),

                  // Reference Number (Optional)
                  _buildReferenceNumberField(paymentProvider),
                  const SizedBox(height: 16),

                  // Remarks (Optional)
                  _buildRemarksField(paymentProvider),
                  const SizedBox(height: 24),

                  // Debug Information (remove in production)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Debug Info:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        Text('Pending challans count: ${paymentProvider.pendingChallans.length}'),
                        Text('Selected challan ID: ${paymentProvider.selectedChallan?.id}'),
                        Text('Selected challan number: ${paymentProvider.selectedChallan?.challanNumber}'),
                        Text('Is fetching: ${paymentProvider.isFetchingPendingChallans}'),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            print('Manual fetch button pressed');
                            paymentProvider.fetchPendingChallans();
                          },
                          child: const Text('Refresh Challans'),
                        ),
                      ],
                    ),
                  ),

                  // Error Message
                  if (paymentProvider.error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              paymentProvider.error!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _isSubmitting || paymentProvider.isLoading
                        ? null
                        : () => _handleSubmit(paymentProvider),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSubmitting || paymentProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Process Payment',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPendingChallansDropdown(PaymentProvider paymentProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Pending Challan *',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: paymentProvider.pendingChallans.isNotEmpty 
              ? paymentProvider.selectedChallan?.id 
              : null,
          decoration: InputDecoration(
            hintText: 'Select a pending challan',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            errorText: paymentProvider.validationErrors['challan'],
            suffixIcon: paymentProvider.isFetchingPendingChallans
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => paymentProvider.fetchPendingChallans(),
                    tooltip: 'Refresh pending challans',
                  ),
          ),
          items: paymentProvider.pendingChallans.isEmpty 
              ? [
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text('No pending challans available'),
                  )
                ]
              : paymentProvider.pendingChallans.map((challan) {
                  return DropdownMenuItem<int>(
                    value: challan.id,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Challan: ${challan.challanNumber}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Order: ${challan.requisition?.orderNumber ?? 'N/A'} - ${challan.requisition?.brickType?.name ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          'Amount: ₹${challan.requisition?.totalAmount ?? '0'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          onChanged: (value) {
            print('Dropdown changed - Selected value: $value (type: ${value.runtimeType})');
            if (value != null) {
              final selectedChallan = paymentProvider.pendingChallans
                  .firstWhere(
                    (challan) => challan.id == value,
                    orElse: () {
                      print('Could not find challan with ID: $value');
                      throw Exception('Challan not found');
                    },
                  );
              print('Found challan: ${selectedChallan.id} - ${selectedChallan.challanNumber}');
              paymentProvider.setSelectedChallan(selectedChallan);
            } else {
              print('Null value selected in dropdown');
              paymentProvider.setSelectedChallan(null);
            }
          },
          onTap: () {
            // Fetch fresh data each time dropdown is opened
            paymentProvider.fetchPendingChallans();
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a pending challan';
            }
            return null;
          },
        ),
        if (paymentProvider.pendingChallans.isEmpty && !paymentProvider.isFetchingPendingChallans)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'No pending challans available',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildChallanDetailsCard(PaymentProvider paymentProvider) {
    return Card(
      elevation: 2,
      color: Theme.of(context).primaryColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Challan Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(height: 24),
            _buildDetailRow('Challan Number', paymentProvider.challanNumber),
            const SizedBox(height: 8),
            _buildDetailRow('Order Number', paymentProvider.orderNumber),
            const SizedBox(height: 8),
            _buildDetailRow('Brick Type', paymentProvider.brickTypeName),
            const SizedBox(height: 8),
            _buildDetailRow('Quantity', paymentProvider.quantity),
            const SizedBox(height: 8),
            _buildDetailRow('Customer Phone', paymentProvider.customerPhone),
            const SizedBox(height: 8),
            _buildDetailRow('Customer Address', paymentProvider.customerAddress),
            const SizedBox(height: 8),
            _buildDetailRow('Vehicle Number', paymentProvider.vehicleNumber),
            const SizedBox(height: 8),
            _buildDetailRow('Driver Name', paymentProvider.driverName),
            const Divider(height: 24),
            _buildDetailRow(
              'Total Amount',
              '₹${paymentProvider.totalAmount}',
              isHighlighted: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlighted = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
              color: isHighlighted ? Colors.black : Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : 'N/A',
            style: TextStyle(
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w400,
              fontSize: isHighlighted ? 16 : 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountReceivedField(PaymentProvider paymentProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount Received *',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: paymentProvider.amountReceived,
          decoration: InputDecoration(
            hintText: 'Enter received amount',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            errorText: paymentProvider.validationErrors['amountReceived'],
            prefixIcon: const Icon(Icons.currency_rupee),
            helperText: paymentProvider.totalAmount.isNotEmpty
                ? 'Total amount: ₹${paymentProvider.totalAmount}'
                : null,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          onChanged: (value) {
            paymentProvider.setAmountReceived(value);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter payment amount';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount';
            }
            if (paymentProvider.totalAmount.isNotEmpty) {
              final totalAmount = double.tryParse(paymentProvider.totalAmount) ?? 0.0;
              if (amount > totalAmount) {
                return 'Amount cannot exceed total amount (₹$totalAmount)';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPaymentMethodField(PaymentProvider paymentProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method (Optional)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: paymentProvider.paymentMethod.isEmpty ? null : paymentProvider.paymentMethod,
          decoration: InputDecoration(
            hintText: 'Select payment method',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.payment_outlined),
          ),
          items: const [
            DropdownMenuItem(value: 'Cash', child: Text('Cash')),
            DropdownMenuItem(value: 'Cheque', child: Text('Cheque')),
            DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer')),
            DropdownMenuItem(value: 'UPI', child: Text('UPI')),
          ],
          onChanged: (value) {
            if (value != null) {
              paymentProvider.setPaymentMethod(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildReferenceNumberField(PaymentProvider paymentProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reference Number (Optional)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: paymentProvider.referenceNumber,
          decoration: InputDecoration(
            hintText: 'Enter reference number',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.confirmation_number_outlined),
          ),
          textCapitalization: TextCapitalization.characters,
          onChanged: (value) {
            paymentProvider.setReferenceNumber(value.isEmpty ? null : value);
          },
        ),
      ],
    );
  }

  Widget _buildRemarksField(PaymentProvider paymentProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Remarks (Optional)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: paymentProvider.remarks,
          decoration: InputDecoration(
            hintText: 'Enter payment remarks',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.note_outlined),
          ),
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (value) {
            paymentProvider.setRemarks(value.isEmpty ? null : value);
          },
        ),
      ],
    );
  }

  Future<void> _handleSubmit(PaymentProvider paymentProvider) async {
    // Clear previous errors
    paymentProvider.clearError();

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await paymentProvider.createPayment();

      if (!mounted) return;

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              paymentProvider.successMessage ?? 'Payment processed successfully',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navigate back to dashboard
        Navigator.of(context).pop(true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Clear form when leaving screen
    final paymentProvider = context.read<PaymentProvider>();
    paymentProvider.clearForm();
    super.dispose();
  }
}
