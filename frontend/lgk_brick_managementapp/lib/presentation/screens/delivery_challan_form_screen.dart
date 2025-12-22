import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business/providers/requisition_provider.dart';
import '../../business/providers/delivery_challan_provider.dart';
import '../../core/di/service_locator.dart';
import '../../data/models/requisition.dart';
import '../../data/models/delivery_challan_request.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/message_display.dart';
import '../widgets/enhanced_form_field.dart';
import '../../core/utils/formatters.dart';

/// Screen for creating delivery challans
/// 
/// Provides a form to create delivery challans with order selection,
/// vehicle details, and remarks.
class DeliveryChallanFormScreen extends StatefulWidget {
  const DeliveryChallanFormScreen({super.key});

  @override
  State<DeliveryChallanFormScreen> createState() => _DeliveryChallanFormScreenState();
}

class _DeliveryChallanFormScreenState extends State<DeliveryChallanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late RequisitionProvider _requisitionProvider;
  late DeliveryChallanProvider _challanProvider;

  // Form fields
  Requisition? _selectedOrder;
  final _vehicleNumberController = TextEditingController();
  final _driverNameController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _remarksController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _requisitionProvider = getIt<RequisitionProvider>();
    _challanProvider = getIt<DeliveryChallanProvider>();
    _loadPendingOrders();
  }

  Future<void> _loadPendingOrders() async {
    // Load pending orders for dropdown
    await _challanProvider.fetchPendingOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Delivery Challan'),
        elevation: 0,
      ),
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: _challanProvider),
          ChangeNotifierProvider.value(value: _requisitionProvider),
        ],
        child: Consumer<DeliveryChallanProvider>(
          builder: (context, challanProvider, child) {
            return LoadingOverlay(
              isLoading: _isSubmitting,
              message: 'Creating delivery challan...',
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Card
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                'DELIVERY CHALLAN',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Date: ${Formatters.date(DateTime.now())}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Order Number Dropdown
                      _buildOrderNumberDropdown(challanProvider),
                      const SizedBox(height: 16),
                      
                      // Auto-filled Order Details (if order selected)
                      if (_selectedOrder != null) ...[
                        _buildOrderDetailsCard(),
                        const SizedBox(height: 24),
                      ],
                      
                      // Vehicle Details Section
                      Text(
                        'Vehicle Details',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildVehicleNumberField(),
                      const SizedBox(height: 16),
                      
                      _buildDriverNameField(),
                      const SizedBox(height: 16),
                      
                      _buildVehicleTypeField(),
                      const SizedBox(height: 24),
                      
                      // Remarks Section
                      _buildRemarksField(),
                      const SizedBox(height: 32),
                      
                      // Error Message
                      if (challanProvider.error != null)
                        MessageDisplay.error(
                          challanProvider.error!,
                          onDismiss: () => challanProvider.clearError(),
                          margin: const EdgeInsets.only(bottom: 16),
                        ),
                      
                      // Create Challan Button
                      ElevatedButton(
                        onPressed: _selectedOrder != null && !_isSubmitting
                            ? _handleSubmit
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          _isSubmitting ? 'CREATING...' : 'CREATE CHALLAN',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderNumberDropdown(DeliveryChallanProvider challanProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order No *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<Requisition>(
          value: _selectedOrder,
          decoration: InputDecoration(
            hintText: 'Select Order Number',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.receipt_long),
          ),
          items: challanProvider.pendingOrders.map((order) {
            return DropdownMenuItem<Requisition>(
              value: order,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    order.orderNumber,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${order.customerName} - ₹${order.totalAmount}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedOrder = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select an order number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildOrderDetailsCard() {
    return Card(
      elevation: 2,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Type', _selectedOrder!.brickType?.name ?? 'N/A'),
            _buildDetailRow('Quantity', '${_selectedOrder!.quantity} ${_selectedOrder!.brickType?.unit ?? ''}'),
            _buildDetailRow('Customer', _selectedOrder!.customerName),
            _buildDetailRow('Phone', _selectedOrder!.customerPhone),
            _buildDetailRow('Location', _selectedOrder!.customerLocation ?? 'N/A'),
            _buildDetailRow('Amount', '₹${_selectedOrder!.totalAmount}'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
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

  Widget _buildVehicleNumberField() {
    return EnhancedTextFormField(
      controller: _vehicleNumberController,
      labelText: 'Vehicle Number *',
      hintText: 'Enter vehicle number (e.g., MH12AB1234)',
      prefixIcon: const Icon(Icons.local_shipping),
      textCapitalization: TextCapitalization.characters,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter vehicle number';
        }
        if (value.length < 6) {
          return 'Please enter a valid vehicle number';
        }
        return null;
      },
    );
  }

  Widget _buildDriverNameField() {
    return EnhancedTextFormField(
      controller: _driverNameController,
      labelText: 'Driver Name',
      hintText: 'Enter driver name (optional)',
      prefixIcon: const Icon(Icons.person),
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        // Optional field - only validate if not empty
        if (value != null && value.isNotEmpty && value.length < 2) {
          return 'Driver name must be at least 2 characters';
        }
        return null;
      },
    );
  }

  Widget _buildVehicleTypeField() {
    return EnhancedTextFormField(
      controller: _vehicleTypeController,
      labelText: 'Vehicle Type',
      hintText: 'Enter vehicle type (e.g., Truck, Tempo, Mini Truck) - optional',
      prefixIcon: const Icon(Icons.fire_truck),
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        // Optional field - no validation required
        return null;
      },
    );
  }

  Widget _buildRemarksField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Remarks',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _remarksController,
          decoration: InputDecoration(
            hintText: 'Enter any remarks or special instructions',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.note_add),
          ),
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Create delivery challan request
      final request = DeliveryChallanRequest(
        requisitionId: _selectedOrder!.id,
        vehicleNumber: _vehicleNumberController.text.trim(),
        driverName: _driverNameController.text.trim().isEmpty 
            ? null 
            : _driverNameController.text.trim(),
        vehicleType: _vehicleTypeController.text.trim().isEmpty 
            ? null 
            : _vehicleTypeController.text.trim(),
        location: _selectedOrder!.customerLocation ?? 'N/A',
        remarks: _remarksController.text.trim().isEmpty 
            ? null 
            : _remarksController.text.trim(),
      );

      // Call the provider to create delivery challan
      final success = await _challanProvider.createDeliveryChallan(request);
      
      if (!mounted) return;

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delivery challan created for ${_selectedOrder!.orderNumber}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate back
        Navigator.of(context).pop();
      } else {
        // Error is handled by the provider and displayed in the UI
        // No need to show additional error message here
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create delivery challan: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
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
    _vehicleNumberController.dispose();
    _driverNameController.dispose();
    _vehicleTypeController.dispose();
    _remarksController.dispose();
    super.dispose();
  }
}

