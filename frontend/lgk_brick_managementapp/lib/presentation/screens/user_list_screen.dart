import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business/providers/user_management_provider.dart';
import '../../data/models/user.dart';
import 'user_form_screen.dart';

/// User list screen with search and filtering
/// 
/// Displays list of users with search, role filter, department filter,
/// and status filter capabilities. Allows navigation to user form for
/// creating and editing users.
class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<UserManagementProvider>();
      // Clear any previous errors before initializing
      provider.clearError();
      provider.initialize().then((_) {
        if (!provider.isLoading && provider.error == null) {
          provider.fetchUsers();
        }
      }).catchError((error) {
        print('UserListScreen initialization error: $error');
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(child: _buildUserList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToUserForm(null),
        icon: const Icon(Icons.add),
        label: const Text('Add User'),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        children: [
          // Search field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search users...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<UserManagementProvider>().setSearchQuery(null);
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              if (value.isEmpty) {
                context.read<UserManagementProvider>().setSearchQuery(null);
              }
            },
            onSubmitted: (value) {
              context.read<UserManagementProvider>().setSearchQuery(
                    value.isEmpty ? null : value,
                  );
            },
          ),
          const SizedBox(height: 12),
          // Filter chips
          _buildFilterChips(),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Consumer<UserManagementProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Role filter
              _buildRoleFilterChip(provider),
              const SizedBox(width: 8),
              // Department filter
              _buildDepartmentFilterChip(provider),
              const SizedBox(width: 8),
              // Status filter
              _buildStatusFilterChip(provider),
              const SizedBox(width: 8),
              // Clear filters
              if (provider.filterRoleId != null ||
                  provider.filterDepartmentId != null ||
                  provider.filterStatus != null)
                ActionChip(
                  label: const Text('Clear Filters'),
                  onPressed: () => provider.clearFilters(),
                  avatar: const Icon(Icons.clear, size: 18),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoleFilterChip(UserManagementProvider provider) {
    return FilterChip(
      label: Text(
        provider.filterRoleId != null
            ? provider.roles
                    .firstWhere((r) => r.id == provider.filterRoleId)
                    .name
            : 'All Roles',
      ),
      selected: provider.filterRoleId != null,
      onSelected: (_) => _showRoleFilterDialog(provider),
    );
  }

  Widget _buildDepartmentFilterChip(UserManagementProvider provider) {
    return FilterChip(
      label: Text(
        provider.filterDepartmentId != null
            ? provider.departments
                    .firstWhere((d) => d.id == provider.filterDepartmentId)
                    .name
            : 'All Departments',
      ),
      selected: provider.filterDepartmentId != null,
      onSelected: (_) => _showDepartmentFilterDialog(provider),
    );
  }

  Widget _buildStatusFilterChip(UserManagementProvider provider) {
    return FilterChip(
      label: Text(
        provider.filterStatus != null
            ? provider.filterStatus!.toUpperCase()
            : 'All Status',
      ),
      selected: provider.filterStatus != null,
      onSelected: (_) => _showStatusFilterDialog(provider),
    );
  }

  Widget _buildUserList() {
    return Consumer<UserManagementProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.users.isEmpty) {
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
                  onPressed: () => provider.fetchUsers(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No users found',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchUsers(),
          child: ListView.builder(
            itemCount: provider.users.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final user = provider.users[index];
              return _buildUserCard(user);
            },
          ),
        );
      },
    );
  }

  Widget _buildUserCard(User user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: user.isActive ? Colors.green : Colors.grey,
          child: Text(
            user.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(user.email),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildBadge(user.roleName, Colors.blue),
                const SizedBox(width: 8),
                if (user.departmentName.isNotEmpty)
                  _buildBadge(user.departmentName, Colors.orange),
                const SizedBox(width: 8),
                _buildBadge(
                  user.status.toUpperCase(),
                  user.isActive ? Colors.green : Colors.grey,
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleUserAction(value, user),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: user.isActive ? 'deactivate' : 'activate',
              child: Row(
                children: [
                  Icon(
                    user.isActive ? Icons.block : Icons.check_circle,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(user.isActive ? 'Deactivate' : 'Activate'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _navigateToUserForm(user),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _handleUserAction(String action, User user) {
    switch (action) {
      case 'edit':
        _navigateToUserForm(user);
        break;
      case 'activate':
      case 'deactivate':
        _confirmStatusChange(user);
        break;
      case 'delete':
        _confirmDelete(user);
        break;
    }
  }

  Future<void> _navigateToUserForm(User? user) async {
    final provider = context.read<UserManagementProvider>();
    
    // Ensure provider is initialized before navigation
    if (provider.roles.isEmpty || provider.departments.isEmpty) {
      // Show loading dialog while initializing
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      try {
        await provider.initialize();
        if (mounted) Navigator.pop(context); // Close loading dialog
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load form data: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
    }

    if (!mounted) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: provider,
          child: UserFormScreen(user: user),
        ),
      ),
    );

    if (result == true && mounted) {
      provider.fetchUsers();
    }
  }

  void _confirmStatusChange(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user.isActive ? 'Deactivate' : 'Activate'} User'),
        content: Text(
          'Are you sure you want to ${user.isActive ? 'deactivate' : 'activate'} ${user.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateUserStatus(user);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteUser(user);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateUserStatus(User user) async {
    final provider = context.read<UserManagementProvider>();
    final newStatus = user.isActive ? 'inactive' : 'active';
    final success = await provider.updateUserStatus(user.id, newStatus);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.successMessage ?? 'Status updated')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to update status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteUser(User user) async {
    final provider = context.read<UserManagementProvider>();
    final success = await provider.deleteUser(user.id);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.successMessage ?? 'User deleted')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to delete user'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showRoleFilterDialog(UserManagementProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Roles'),
              onTap: () {
                provider.setRoleFilter(null);
                Navigator.pop(context);
              },
            ),
            ...provider.roles.map((role) => ListTile(
                  title: Text(role.name),
                  onTap: () {
                    provider.setRoleFilter(role.id);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showDepartmentFilterDialog(UserManagementProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Department'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Departments'),
              onTap: () {
                provider.setDepartmentFilter(null);
                Navigator.pop(context);
              },
            ),
            ...provider.departments.map((dept) => ListTile(
                  title: Text(dept.name),
                  onTap: () {
                    provider.setDepartmentFilter(dept.id);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showStatusFilterDialog(UserManagementProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Status'),
              onTap: () {
                provider.setStatusFilter(null);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Active'),
              onTap: () {
                provider.setStatusFilter('active');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Inactive'),
              onTap: () {
                provider.setStatusFilter('inactive');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
