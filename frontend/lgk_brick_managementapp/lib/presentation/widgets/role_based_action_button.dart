import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business/providers/auth_provider.dart';
import '../../business/providers/user_management_provider.dart';
import '../../business/providers/brick_type_provider.dart';
import '../../core/di/service_locator.dart';
import '../screens/user_form_screen.dart';
import '../screens/brick_type_form_screen.dart';

/// Floating action button that adapts based on user role
/// 
/// Provides role-specific quick actions on dashboard screens.
class RoleBasedActionButton extends StatelessWidget {
  const RoleBasedActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userRole = authProvider.currentUser?.role?.name?.toLowerCase();

    // Return appropriate FAB based on role
    switch (userRole) {
      case 'sales':
      case 'sales executive':
        return FloatingActionButton.extended(
          onPressed: () {
            // TODO: Navigate to requisition creation
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Create Requisition - Coming Soon'),
              ),
            );
          },
          icon: const Icon(Icons.add_shopping_cart),
          label: const Text('New Order'),
        );

      case 'logistics':
        return FloatingActionButton.extended(
          onPressed: () {
            // TODO: Navigate to challan creation
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Create Challan - Coming Soon'),
              ),
            );
          },
          icon: const Icon(Icons.local_shipping),
          label: const Text('New Challan'),
        );

      case 'accounts':
        return FloatingActionButton.extended(
          onPressed: () {
            // TODO: Navigate to payment processing
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Process Payment - Coming Soon'),
              ),
            );
          },
          icon: const Icon(Icons.payment),
          label: const Text('New Payment'),
        );

      case 'admin':
        return FloatingActionButton(
          onPressed: () {
            // Show admin quick actions menu
            _showAdminQuickActions(context);
          },
          child: const Icon(Icons.add),
        );

      default:
        // No FAB for unknown roles
        return const SizedBox.shrink();
    }
  }

  void _showAdminQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Add User'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                      create: (_) => getIt<UserManagementProvider>()..initialize(),
                      child: const UserFormScreen(),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_box),
              title: const Text('Add Brick Type'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                      create: (_) => getIt<BrickTypeProvider>(),
                      child: const BrickTypeFormScreen(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
