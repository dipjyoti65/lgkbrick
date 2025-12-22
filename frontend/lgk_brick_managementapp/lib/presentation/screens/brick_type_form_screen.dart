import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business/providers/brick_type_provider.dart';
import '../../data/models/brick_type.dart';
import '../../data/models/brick_type_request.dart';
import '../../core/utils/validators.dart';

/// Brick type form screen for creating and editing brick types
/// 
/// Provides form with price validation and update confirmation
/// for brick type data.
class BrickTypeFormScreen extends StatefulWidget {
  final BrickType? brickType;

  const BrickTypeFormScreen({super.key, this.brickType});

  @override
  State<BrickTypeFormScreen> createState() => _BrickTypeFormScreenState();
}

class _BrickTypeFormScreenState extends State<BrickTypeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _unitController = TextEditingController();
  final _categoryController = TextEditingController();

  String _selectedStatus = 'active';
  
  // Store field-specific validation errors
  Map<String, String> _fieldErrors = {};

  bool get isEditing => widget.brickType != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.brickType!.name;
      _descriptionController.text = widget.brickType!.description ?? '';
      _priceController.text = widget.brickType!.currentPrice ?? '';
      _unitController.text = widget.brickType!.unit ?? '';
      _categoryController.text = widget.brickType!.category ?? '';
      _selectedStatus = widget.brickType!.status;
    }
    // Remove default unit setting since it's now optional
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _unitController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Brick Type' : 'Add Brick Type'),
        elevation: 0,
      ),
      body: Consumer<BrickTypeProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildNameField(),
                  const SizedBox(height: 16),
                  _buildDescriptionField(),
                  const SizedBox(height: 16),
                  _buildPriceField(),
                  const SizedBox(height: 16),
                  _buildUnitField(),
                  const SizedBox(height: 16),
                  _buildCategoryField(),
                  const SizedBox(height: 16),
                  if (isEditing) _buildStatusDropdown(),
                  const SizedBox(height: 24),
                  _buildSubmitButton(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Brick Type Name',
        hintText: 'Enter brick type name',
        prefixIcon: const Icon(Icons.category),
        border: const OutlineInputBorder(),
        errorText: _fieldErrors['name'],
      ),
      validator: (value) => Validators.required(value, fieldName: 'Name'),
      textCapitalization: TextCapitalization.words,
      onChanged: (value) {
        // Clear field error when user starts typing
        if (_fieldErrors.containsKey('name')) {
          setState(() {
            _fieldErrors.remove('name');
          });
        }
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description',
        hintText: 'Enter description (optional)',
        prefixIcon: Icon(Icons.description),
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceController,
      decoration: InputDecoration(
        labelText: 'Price (Optional)',
        hintText: 'Enter price (optional)',
        prefixIcon: const Icon(Icons.attach_money),
        prefixText: '₹ ',
        border: const OutlineInputBorder(),
        errorText: _fieldErrors['current_price'],
        helperText: isEditing
            ? 'Changing price will affect future orders'
            : 'Leave empty if price is not determined yet',
        helperStyle: TextStyle(
          color: Colors.orange[700],
          fontStyle: FontStyle.italic,
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        // Price is now optional, so only validate if provided
        if (value != null && value.isNotEmpty) {
          final price = double.tryParse(value);
          if (price == null) {
            return 'Please enter a valid number';
          }
          if (price < 0) {
            return 'Price cannot be negative';
          }
        }
        return null;
      },
      onChanged: (value) {
        // Clear field error when user starts typing
        if (_fieldErrors.containsKey('current_price')) {
          setState(() {
            _fieldErrors.remove('current_price');
          });
        }
      },
    );
  }

  Widget _buildUnitField() {
    return TextFormField(
      controller: _unitController,
      decoration: const InputDecoration(
        labelText: 'Unit (Optional)',
        hintText: 'e.g., piece, kg, ton (optional)',
        prefixIcon: Icon(Icons.straighten),
        border: OutlineInputBorder(),
      ),
      // Remove validator since unit is now optional
    );
  }

  Widget _buildCategoryField() {
    return TextFormField(
      controller: _categoryController,
      decoration: InputDecoration(
        labelText: 'Category',
        hintText: 'Enter category (optional)',
        prefixIcon: const Icon(Icons.label),
        border: const OutlineInputBorder(),
        errorText: _fieldErrors['category'],
      ),
      textCapitalization: TextCapitalization.words,
      onChanged: (value) {
        // Clear field error when user starts typing
        if (_fieldErrors.containsKey('category')) {
          setState(() {
            _fieldErrors.remove('category');
          });
        }
      },
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: const InputDecoration(
        labelText: 'Status',
        prefixIcon: Icon(Icons.toggle_on),
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'active', child: Text('Active')),
        DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedStatus = value!;
        });
      },
    );
  }

  Widget _buildSubmitButton(BrickTypeProvider provider) {
    return ElevatedButton(
      onPressed: provider.isLoading ? null : _handleSubmit,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: provider.isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(isEditing ? 'Update Brick Type' : 'Create Brick Type'),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Clear previous field errors
    setState(() {
      _fieldErrors.clear();
    });

    // Show confirmation dialog if editing and price changed
    if (isEditing && 
        _priceController.text.trim() != (widget.brickType!.currentPrice ?? '') &&
        _priceController.text.trim().isNotEmpty) {
      final confirmed = await _showPriceChangeConfirmation();
      if (!confirmed) return;
    }

    final provider = context.read<BrickTypeProvider>();
    bool success;

    if (isEditing) {
      final request = BrickTypeRequest(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        currentPrice: _priceController.text.trim().isEmpty
            ? null
            : _priceController.text.trim(),
        unit: _unitController.text.trim().isEmpty
            ? null
            : _unitController.text.trim(),
        category: _categoryController.text.trim().isEmpty
            ? null
            : _categoryController.text.trim(),
        status: _selectedStatus,
      );
      success = await provider.updateBrickType(widget.brickType!.id, request);
    } else {
      final request = BrickTypeRequest(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        currentPrice: _priceController.text.trim().isEmpty
            ? null
            : _priceController.text.trim(),
        unit: _unitController.text.trim().isEmpty
            ? null
            : _unitController.text.trim(),
        category: _categoryController.text.trim().isEmpty
            ? null
            : _categoryController.text.trim(),
      );
      success = await provider.createBrickType(request);
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.successMessage ??
                  (isEditing ? 'Brick type updated' : 'Brick type created'),
            ),
          ),
        );
        Navigator.pop(context, true);
      } else {
        // Check if the error is a ValidationException with field-specific errors
        _handleValidationErrors(provider);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.error ??
                  (isEditing
                      ? 'Failed to update brick type'
                      : 'Failed to create brick type'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Handle validation errors by extracting field-specific errors
  void _handleValidationErrors(BrickTypeProvider provider) {
    final validationException = provider.lastValidationException;
    if (validationException != null) {
      setState(() {
        _fieldErrors = validationException.getAllErrors();
      });
    }
  }

  Future<bool> _showPriceChangeConfirmation() async {
    final oldPrice = widget.brickType!.currentPrice ?? 'Not set';
    final newPrice = _priceController.text.trim().isEmpty ? 'Not set' : _priceController.text;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Price Change'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('You are changing the price of this brick type.'),
            const SizedBox(height: 8),
            Text(
              'Old Price: ₹$oldPrice',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'New Price: ₹$newPrice',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'This will affect all future orders.',
              style: TextStyle(
                color: Colors.orange[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
