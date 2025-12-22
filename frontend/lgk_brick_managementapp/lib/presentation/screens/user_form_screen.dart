import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business/providers/user_management_provider.dart';
import '../../data/models/user.dart';
import '../../data/models/user_request.dart';
import '../../core/utils/validators.dart';

/// User form screen for creating and editing users
/// 
/// Provides form with role selection, department assignment,
/// and validation for user data.
class UserFormScreen extends StatefulWidget {
  final User? user;

  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  int? _selectedRoleId;
  int? _selectedDepartmentId;
  String _selectedStatus = 'active';
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;
  
  // Store field-specific validation errors
  Map<String, String> _fieldErrors = {};

  bool get isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.user!.name;
      _emailController.text = widget.user!.email;
      _selectedRoleId = widget.user!.roleId;
      _selectedDepartmentId = widget.user!.departmentId;
      _selectedStatus = widget.user!.status;
    }
    
    // Ensure provider is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final provider = context.read<UserManagementProvider>();
        if (provider.roles.isEmpty || provider.departments.isEmpty) {
          provider.initialize();
        }
      } catch (e) {
        // Handle provider not found error gracefully
        print('Provider initialization error: $e');
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit User' : 'Add User'),
        elevation: 0,
      ),
      body: Consumer<UserManagementProvider>(
        builder: (context, provider, child) {
          // Show loading while initializing
          if (provider.isLoading && provider.roles.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show error if provider failed to initialize
          if (provider.error != null && provider.roles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load form data',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => provider.initialize(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildNameField(),
                  const SizedBox(height: 16),
                  _buildEmailField(),
                  const SizedBox(height: 16),
                  if (!isEditing) ...[
                    _buildPasswordField(),
                    const SizedBox(height: 16),
                    _buildPasswordConfirmField(),
                    const SizedBox(height: 16),
                  ],
                  _buildRoleDropdown(provider),
                  const SizedBox(height: 16),
                  _buildDepartmentDropdown(provider),
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
        labelText: 'Full Name',
        hintText: 'Enter full name',
        prefixIcon: const Icon(Icons.person),
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

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'Enter email address',
        prefixIcon: const Icon(Icons.email),
        border: const OutlineInputBorder(),
        errorText: _fieldErrors['email'],
      ),
      keyboardType: TextInputType.emailAddress,
      validator: Validators.email,
      onChanged: (value) {
        // Clear field error when user starts typing
        if (_fieldErrors.containsKey('email')) {
          setState(() {
            _fieldErrors.remove('email');
          });
        }
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter password',
        prefixIcon: const Icon(Icons.lock),
        border: const OutlineInputBorder(),
        errorText: _fieldErrors['password'],
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      obscureText: _obscurePassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password is required';
        }
        if (value.length < 8) {
          return 'Password must be at least 8 characters';
        }
        return null;
      },
      onChanged: (value) {
        // Clear field error when user starts typing
        if (_fieldErrors.containsKey('password')) {
          setState(() {
            _fieldErrors.remove('password');
          });
        }
      },
    );
  }

  Widget _buildPasswordConfirmField() {
    return TextFormField(
      controller: _passwordConfirmController,
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        hintText: 'Re-enter password',
        prefixIcon: const Icon(Icons.lock_outline),
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePasswordConfirm ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscurePasswordConfirm = !_obscurePasswordConfirm;
            });
          },
        ),
      ),
      obscureText: _obscurePasswordConfirm,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please confirm password';
        }
        if (value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Widget _buildRoleDropdown(UserManagementProvider provider) {
    return DropdownButtonFormField<int>(
      value: _selectedRoleId,
      decoration: InputDecoration(
        labelText: 'Role',
        hintText: 'Select role',
        prefixIcon: const Icon(Icons.badge),
        border: const OutlineInputBorder(),
        errorText: _fieldErrors['role_id'],
      ),
      items: provider.roles.map((role) {
        return DropdownMenuItem<int>(
          value: role.id,
          child: Text(role.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedRoleId = value;
          _fieldErrors.remove('role_id'); // Clear error when user selects
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select a role';
        }
        return null;
      },
    );
  }

  Widget _buildDepartmentDropdown(UserManagementProvider provider) {
    return DropdownButtonFormField<int>(
      value: _selectedDepartmentId,
      decoration: InputDecoration(
        labelText: 'Department',
        hintText: 'Select department (optional)',
        prefixIcon: const Icon(Icons.business),
        border: const OutlineInputBorder(),
        errorText: _fieldErrors['department_id'],
      ),
      items: [
        const DropdownMenuItem<int>(
          value: null,
          child: Text('No Department'),
        ),
        ...provider.departments.map((dept) {
          return DropdownMenuItem<int>(
            value: dept.id,
            child: Text(dept.name),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          _selectedDepartmentId = value;
          _fieldErrors.remove('department_id'); // Clear error when user selects
        });
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

  Widget _buildSubmitButton(UserManagementProvider provider) {
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
          : Text(isEditing ? 'Update User' : 'Create User'),
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

    final provider = context.read<UserManagementProvider>();
    bool success;

    if (isEditing) {
      final request = UpdateUserRequest(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        roleId: _selectedRoleId!,
        departmentId: _selectedDepartmentId,
        status: _selectedStatus,
      );
      success = await provider.updateUser(widget.user!.id, request);
    } else {
      final request = CreateUserRequest(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _passwordConfirmController.text,
        roleId: _selectedRoleId!,
        departmentId: _selectedDepartmentId,
      );
      success = await provider.createUser(request);
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.successMessage ??
                  (isEditing ? 'User updated' : 'User created'),
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
                  (isEditing ? 'Failed to update user' : 'Failed to create user'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Handle validation errors by extracting field-specific errors
  void _handleValidationErrors(UserManagementProvider provider) {
    final validationException = provider.lastValidationException;
    if (validationException != null) {
      setState(() {
        _fieldErrors = validationException.getAllErrors();
      });
    }
  }
}
