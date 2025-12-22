import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business/providers/auth_provider.dart';
import '../../business/providers/delivery_challan_provider.dart';
import '../../core/di/service_locator.dart';
import '../widgets/app_drawer.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/role_based_action_button.dart';
import 'delivery_challan_form_screen.dart';
import 'pending_orders_screen.dart';

/// Logistics dashboard screen
/// 
/// Displays logistics-specific features including pending orders,
/// delivery management, and vehicle tracking.
class LogisticsDashboardScreen extends StatefulWidget {
  const LogisticsDashboardScreen({super.key});

  @override
  State<LogisticsDashboardScreen> createState() => _LogisticsDashboardScreenState();
}

class _LogisticsDashboardScreenState extends State<LogisticsDashboardScreen> {
  late DeliveryChallanProvider _challanProvider;

  @override
  void initState() {
    super.initState();
    _challanProvider = getIt<DeliveryChallanProvider>();
    // Fetch pending orders count on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _challanProvider.fetchPendingOrders();
      _challanProvider.fetchDeliveryChallans();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Logistics Dashboard'),
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: ChangeNotifierProvider.value(
        value: _challanProvider,
        child: Consumer<DeliveryChallanProvider>(
          builder: (context, challanProvider, child) {
            return Column(
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
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.name ?? 'Logistics',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.role?.name ?? 'Logistics Manager',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
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
                        title: 'Pending Orders',
                        description: 'Orders awaiting delivery',
                        icon: Icons.pending_actions,
                        iconColor: Colors.orange,
                        badgeCount: challanProvider.pendingOrders.length,
                        onTap: () {
                          // Navigate to pending orders screen
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const PendingOrdersScreen(),
                            ),
                          );
                        },
                      ),
                      DashboardCard(
                        title: 'Create Challan',
                        description: 'New delivery challan',
                        icon: Icons.local_shipping,
                        iconColor: Colors.blue,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const DeliveryChallanFormScreen(),
                            ),
                          );
                        },
                      ),
                      DashboardCard(
                        title: 'Recent Deliveries',
                        description: 'View delivery history',
                        icon: Icons.delivery_dining,
                        iconColor: Colors.green,
                        badgeCount: challanProvider.deliveryChallans.length,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Delivery History - Coming Soon'),
                            ),
                          );
                        },
                      ),
                      DashboardCard(
                        title: 'Vehicle Management',
                        description: 'Manage vehicles',
                        icon: Icons.directions_car,
                        iconColor: Colors.purple,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Vehicle Management - Coming Soon'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const DeliveryChallanFormScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Challan'),
      ),
    );
  }

  @override
  void dispose() {
    _challanProvider.dispose();
    super.dispose();
  }
}
