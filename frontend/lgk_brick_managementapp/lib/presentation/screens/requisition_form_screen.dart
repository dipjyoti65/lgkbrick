import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../business/providers/requisition_provider.dart';
import '../../business/providers/brick_type_provider.dart';
import '../../data/models/brick_type.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/keyboard_utils.dart';
import '../../core/utils/responsive_utils.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/message_display.dart';
import '../widgets/feedback_manager.dart';
import '../widgets/adaptive_layout.dart';
import '../widgets/enhanced_form_field.dart';

/// Requisition creation form screen
/// 
/// Provides a form for sales executives to create new requisitions with
/// brick type selection, quantity input, customer details, and auto-calculation
/// of total amount.
class RequisitionFormScreen extends StatefulWidget {
  const RequisitionFormScreen({super.key});

  @override
  State<RequisitionFormScreen> createState() => _RequisitionFormScreenState();
}

class _RequisitionFormScreenState extends State<RequisitionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Fetch active brick types when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final brickTypeProvider = context.read<BrickTypeProvider>();
      brickTypeProvider.fetchActiveBrickTypes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Requisition'),
        elevation: 0,
      ),
      body: Consumer2<RequisitionProvider, BrickTypeProvider>(
        builder: (context, requisitionProvider, brickTypeProvider, child) {
          // Show loading indicator while fetching brick types
          if (brickTypeProvider.isLoading && brickTypeProvider.activeBrickTypes.isEmpty) {
            return const Center(
              child: LoadingIndicator(
                message: 'Loading brick types...',
                size: 32,
              ),
            );
          }

          // Show error if brick types failed to load
          if (brickTypeProvider.error != null && brickTypeProvider.activeBrickTypes.isEmpty) {
            return ErrorStateDisplay(
              title: 'Failed to load brick types',
              subtitle: brickTypeProvider.error,
              onRetry: () => brickTypeProvider.fetchActiveBrickTypes(),
            );
          }

          return LoadingOverlay(
            isLoading: _isSubmitting || requisitionProvider.isLoading,
            message: _isSubmitting ? 'Creating requisition...' : 'Loading...',
            child: AdaptiveFormLayout(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Brick Type Dropdown
                      _buildBrickTypeDropdown(requisitionProvider, brickTypeProvider),
                      SizedBox(height: ResponsiveUtils.getResponsiveFormSpacing(context)),

                      // Quantity Input
                      _buildQuantityField(requisitionProvider),
                      SizedBox(height: ResponsiveUtils.getResponsiveFormSpacing(context)),

                      // Entered Price Input
                      _buildEnteredPriceField(requisitionProvider),
                      SizedBox(height: ResponsiveUtils.getResponsiveFormSpacing(context)),

                      // Total Amount Display
                      _buildTotalAmountCard(requisitionProvider),
                      SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 24)),

                      // Customer Details Section
                      Text(
                        'Customer Details',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: (Theme.of(context).textTheme.titleLarge?.fontSize ?? 20) *
                              ResponsiveUtils.getFontSizeMultiplier(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsiveFormSpacing(context)),

                      // Customer Name
                      _buildCustomerNameField(requisitionProvider),
                      SizedBox(height: ResponsiveUtils.getResponsiveFormSpacing(context)),

                      // Customer Phone
                      _buildCustomerPhoneField(requisitionProvider),
                      SizedBox(height: ResponsiveUtils.getResponsiveFormSpacing(context)),

                      // Customer Address
                      _buildCustomerAddressField(requisitionProvider),
                      SizedBox(height: ResponsiveUtils.getResponsiveFormSpacing(context)),

                      // Customer Location (Required)
                      _buildCustomerLocationField(requisitionProvider),
                      SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 24)),

                      // Error Message
                      if (requisitionProvider.error != null)
                        MessageDisplay.error(
                          requisitionProvider.error!,
                          onDismiss: () => requisitionProvider.clearError(),
                          margin: EdgeInsets.only(
                            bottom: ResponsiveUtils.getResponsiveSpacing(context),
                          ),
                        ),

                      // Success Message
                      if (requisitionProvider.successMessage != null)
                        MessageDisplay.success(
                          requisitionProvider.successMessage!,
                          onDismiss: () => requisitionProvider.clearSuccessMessage(),
                          margin: EdgeInsets.only(
                            bottom: ResponsiveUtils.getResponsiveSpacing(context),
                          ),
                        ),

                      // Submit Button
                      EnhancedSubmitButton(
                        formKey: _formKey,
                        isLoading: _isSubmitting || requisitionProvider.isLoading,
                        onPressed: () => _handleSubmit(requisitionProvider),
                        loadingText: 'Creating...',
                        child: const Text('Create Requisition'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBrickTypeDropdown(
    RequisitionProvider requisitionProvider,
    BrickTypeProvider brickTypeProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Brick Type *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: (Theme.of(context).textTheme.titleMedium?.fontSize ?? 16) *
                ResponsiveUtils.getFontSizeMultiplier(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 8)),
        EnhancedDropdownFormField<BrickType>(
          value: requisitionProvider.selectedBrickType,
          labelText: 'Brick Type',
          hintText: 'Select brick type',
          isLoading: brickTypeProvider.isLoading,
          onRefresh: () => brickTypeProvider.fetchActiveBrickTypes(),
          emptyText: 'No brick types available',
          items: brickTypeProvider.activeBrickTypes.map((brickType) {
            return DropdownMenuItem<BrickType>(
              value: brickType,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    brickType.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    brickType.currentPrice != null && brickType.unit != null
                        ? '${Formatters.formatCurrency(brickType.priceAsDouble)} per ${brickType.unit}'
                        : brickType.currentPrice != null
                            ? Formatters.formatCurrency(brickType.priceAsDouble)
                            : brickType.unit != null
                                ? 'Unit: ${brickType.unit}'
                                : 'Price not set',
                    style: TextStyle(
                      fontSize: 12 * ResponsiveUtils.getFontSizeMultiplier(context),
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            requisitionProvider.setSelectedBrickType(value);
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a brick type';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildQuantityField(RequisitionProvider requisitionProvider) {
    final config = FormFieldConfig.quantity();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantity *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: (Theme.of(context).textTheme.titleMedium?.fontSize ?? 16) *
                ResponsiveUtils.getFontSizeMultiplier(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 8)),
        EnhancedTextFormField(
          initialValue: requisitionProvider.quantity,
          labelText: 'Quantity',
          hintText: 'Enter quantity',
          suffixText: requisitionProvider.selectedBrickType?.unit,
          keyboardType: config['keyboardType'],
          textInputAction: config['textInputAction'],
          inputFormatters: config['inputFormatters'],
          textCapitalization: config['textCapitalization'],
          enableSuggestions: config['enableSuggestions'],
          autocorrect: config['autocorrect'],
          successMessage: 'Valid quantity entered',
          onChanged: (value) {
            requisitionProvider.setQuantity(value);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter quantity';
            }
            final qty = double.tryParse(value);
            if (qty == null || qty <= 0) {
              return 'Please enter a valid positive number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildEnteredPriceField(RequisitionProvider requisitionProvider) {
    final config = FormFieldConfig.currency();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Price per ${requisitionProvider.selectedBrickType?.unit ?? 'Unit'} *',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: (Theme.of(context).textTheme.titleMedium?.fontSize ?? 16) *
                    ResponsiveUtils.getFontSizeMultiplier(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            if (requisitionProvider.selectedBrickType != null)
              if (requisitionProvider.selectedBrickType!.currentPrice != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    'Suggested: ₹${requisitionProvider.selectedBrickType!.currentPrice}',
                    style: TextStyle(
                      fontSize: 12 * ResponsiveUtils.getFontSizeMultiplier(context),
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
          ],
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 8)),
        EnhancedTextFormField(
          initialValue: requisitionProvider.enteredPrice,
          labelText: 'Price per ${requisitionProvider.selectedBrickType?.unit ?? 'Unit'}',
          hintText: 'Enter price per ${requisitionProvider.selectedBrickType?.unit?.toLowerCase() ?? 'unit'}',
          prefixText: '₹ ',
          keyboardType: config['keyboardType'],
          textInputAction: config['textInputAction'],
          inputFormatters: config['inputFormatters'],
          textCapitalization: config['textCapitalization'],
          enableSuggestions: config['enableSuggestions'],
          autocorrect: config['autocorrect'],
          successMessage: 'Valid price entered',
          onChanged: (value) {
            requisitionProvider.setEnteredPrice(value);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter price';
            }
            final price = double.tryParse(value);
            if (price == null || price <= 0) {
              return 'Please enter a valid positive price';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTotalAmountCard(RequisitionProvider requisitionProvider) {
    return Card(
      elevation: 2,
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Amount',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              Formatters.formatCurrency(requisitionProvider.calculatedTotal),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerNameField(RequisitionProvider requisitionProvider) {
    final config = FormFieldConfig.name();
    
    return EnhancedTextFormField(
      initialValue: requisitionProvider.customerName,
      labelText: 'Customer Name *',
      hintText: 'Enter customer name',
      prefixIcon: const Icon(Icons.person_outline),
      keyboardType: config['keyboardType'],
      textInputAction: config['textInputAction'],
      inputFormatters: config['inputFormatters'],
      textCapitalization: config['textCapitalization'],
      enableSuggestions: config['enableSuggestions'],
      autocorrect: config['autocorrect'],
      successMessage: 'Valid name entered',
      onChanged: (value) {
        requisitionProvider.setCustomerName(value);
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter customer name';
        }
        if (value.length < 2) {
          return 'Name must be at least 2 characters';
        }
        return null;
      },
    );
  }

  Widget _buildCustomerPhoneField(RequisitionProvider requisitionProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer Phone *',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: requisitionProvider.customerPhone,
          decoration: InputDecoration(
            hintText: 'Enter customer phone',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            errorText: requisitionProvider.validationErrors['customerPhone'],
            prefixIcon: const Icon(Icons.phone_outlined),
          ),
          keyboardType: TextInputType.phone,
          onChanged: (value) {
            requisitionProvider.setCustomerPhone(value);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter customer phone';
            }
            final cleanPhone = value.replaceAll(RegExp(r'[\s-]'), '');
            if (!RegExp(r'^\+?\d{10,15}$').hasMatch(cleanPhone)) {
              return 'Please enter a valid phone number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCustomerAddressField(RequisitionProvider requisitionProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer Address *',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: requisitionProvider.customerAddress,
          decoration: InputDecoration(
            hintText: 'Enter customer address',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            errorText: requisitionProvider.validationErrors['customerAddress'],
            prefixIcon: const Icon(Icons.location_on_outlined),
          ),
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (value) {
            requisitionProvider.setCustomerAddress(value);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter customer address';
            }
            if (value.length < 5) {
              return 'Address must be at least 5 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCustomerLocationField(RequisitionProvider requisitionProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer Location *',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: requisitionProvider.customerLocation,
          decoration: InputDecoration(
            hintText: 'Enter customer location',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            errorText: requisitionProvider.validationErrors['customerLocation'],
            prefixIcon: const Icon(Icons.map_outlined),
          ),
          textCapitalization: TextCapitalization.words,
          onChanged: (value) {
            requisitionProvider.setCustomerLocation(value.isEmpty ? null : value);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter customer location';
            }
            return null;
          },
        ),
      ],
    );
  }

  Future<void> _handleSubmit(RequisitionProvider requisitionProvider) async {
    // Clear previous errors
    requisitionProvider.clearError();

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await requisitionProvider.createRequisition();

      if (!mounted) return;

      if (success) {
        // Show success message using FeedbackManager
        context.showSuccess(
          requisitionProvider.successMessage ?? 'Requisition created successfully',
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
    final requisitionProvider = context.read<RequisitionProvider>();
    requisitionProvider.clearForm();
    super.dispose();
  }
}
