import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business/providers/auth_provider.dart';
import '../../business/providers/requisition_provider.dart';
import '../../business/providers/brick_type_provider.dart';
import '../../core/di/service_locator.dart';
import '../widgets/app_drawer.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/role_based_action_button.dart';
import 'requisition_form_screen.dart';
import 'requisition_list_screen.dart';

/// Sales dashboard screen
/// 
/// Displays sales-specific features including requisition creation,
/// order tracking, and customer management.
class SalesDashboardScreen extends StatefulWidget {
  const SalesDashboardScreen({super.key});

  @override
  State<SalesDashboardScreen> createState() => _SalesDashboardScreenState();
}

class _SalesDashboardScreenState extends State<SalesDashboardScreen> {
  late RequisitionProvider _requisitionProvider;

  @override
  void initState() {
    super.initState();
    _requisitionProvider = getIt<RequisitionProvider>();
    // Fetch requisitions for statistics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requisitionProvider.fetchRequisitions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Dashboard'),
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
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.name ?? 'Sales',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.role?.name ?? 'Sales Executive',
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
            child: ChangeNotifierProvider.value(
              value: _requisitionProvider,
              child: Consumer<RequisitionProvider>(
                builder: (context, requisitionProvider, child) {
                  final totalRequisitions = requisitionProvider.requisitions.length;
                  final submittedRequisitions = requisitionProvider.requisitions
                      .where((r) => r.status == 'submitted')
                      .length;

                  return DashboardCardGrid(
                    cards: [
                      DashboardCard(
                        title: 'Create Requisition',
                        description: 'New customer order',
                        icon: Icons.add_shopping_cart,
                        iconColor: Colors.green,
                        onTap: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MultiProvider(
                                providers: [
                                  ChangeNotifierProvider(
                                    create: (_) => getIt<RequisitionProvider>(),
                                  ),
                                  ChangeNotifierProvider(
                                    create: (_) => getIt<BrickTypeProvider>(),
                                  ),
                                ],
                                child: const RequisitionFormScreen(),
                              ),
                            ),
                          );
                          // Refresh requisitions if a new one was created
                          if (result == true) {
                            _requisitionProvider.fetchRequisitions();
                          }
                        },
                      ),
                      DashboardCard(
                        title: 'My Requisitions',
                        description: 'View all orders',
                        icon: Icons.list_alt,
                        iconColor: Colors.blue,
                        badgeCount: totalRequisitions,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const RequisitionListScreen(
                                title: 'My Requisitions',
                                mode: RequisitionListMode.all,
                              ),
                            ),
                          );
                        },
                      ),
                      DashboardCard(
                        title: 'Pending Orders',
                        description: 'Awaiting processing',
                        icon: Icons.pending_actions,
                        iconColor: Colors.orange,
                        badgeCount: submittedRequisitions,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const RequisitionListScreen(
                                title: 'Pending Orders',
                                mode: RequisitionListMode.pending,
                              ),
                            ),
                          );
                        },
                      ),
                      DashboardCard(
                        title: 'Order History',
                        description: 'View past orders',
                        icon: Icons.history,
                        iconColor: Colors.purple,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const RequisitionListScreen(
                                title: 'Order History',
                                mode: RequisitionListMode.history,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MultiProvider(
                providers: [
                  ChangeNotifierProvider(
                    create: (_) => getIt<RequisitionProvider>(),
                  ),
                  ChangeNotifierProvider(
                    create: (_) => getIt<BrickTypeProvider>(),
                  ),
                ],
                child: const RequisitionFormScreen(),
              ),
            ),
          );
          // Refresh requisitions if a new one was created
          if (result == true) {
            _requisitionProvider.fetchRequisitions();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('New Order'),
        tooltip: 'Create new requisition',
      ),
    );
  }

  @override
  void dispose() {
    _requisitionProvider.dispose();
    super.dispose();
  }
}
