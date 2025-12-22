import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business/providers/auth_provider.dart';
import '../../business/providers/user_management_provider.dart';
import '../../business/providers/brick_type_provider.dart';
import '../../business/providers/order_history_provider.dart';
import '../../core/di/service_locator.dart';
import '../widgets/app_drawer.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/role_based_action_button.dart';
import 'user_list_screen.dart';
import 'brick_type_list_screen.dart';
import 'order_history_screen.dart';

/// Admin dashboard screen
/// 
/// Displays admin-specific features including user management,
/// brick type management, and system overview with navigation.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.name ?? 'Admin',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.role?.name ?? 'Administrator',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          // Dashboard Cards
          Expanded(
            child: DashboardCardGrid(
              cards: [
                DashboardCard(
                  title: 'Order History',
                  description: 'View all orders and payments',
                  icon: Icons.history,
                  iconColor: Colors.purple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MultiProvider(
                          providers: [
                            ChangeNotifierProvider(
                              create: (_) => getIt<OrderHistoryProvider>(),
                            ),
                          ],
                          child: const OrderHistoryScreen(),
                        ),
                      ),
                    );
                  },
                ),
                DashboardCard(
                  title: 'User Management',
                  description: 'Manage users and roles',
                  icon: Icons.people,
                  iconColor: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MultiProvider(
                          providers: [
                            ChangeNotifierProvider(
                              create: (_) => getIt<UserManagementProvider>(),
                            ),
                          ],
                          child: const UserListScreen(),
                        ),
                      ),
                    );
                  },
                ),
                DashboardCard(
                  title: 'Brick Types',
                  description: 'Manage brick catalog',
                  icon: Icons.category,
                  iconColor: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MultiProvider(
                          providers: [
                            ChangeNotifierProvider(
                              create: (_) => getIt<BrickTypeProvider>(),
                            ),
                          ],
                          child: const BrickTypeListScreen(),
                        ),
                      ),
                    );
                  },
                ),
                DashboardCard(
                  title: 'System Reports',
                  description: 'View system analytics',
                  icon: Icons.analytics,
                  iconColor: Colors.green,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('System Reports - Coming Soon'),
                      ),
                    );
                  },
                ),
                DashboardCard(
                  title: 'Settings',
                  description: 'System configuration',
                  icon: Icons.settings,
                  iconColor: Colors.teal,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Settings - Coming Soon'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: const RoleBasedActionButton(),
    );
  }
}
