import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business/providers/auth_provider.dart';
import '../../business/providers/payment_provider.dart';
import '../../core/di/service_locator.dart';
import '../widgets/app_drawer.dart';
import '../widgets/dashboard_card.dart';

import 'payment_form_screen.dart';
import 'all_challans_screen.dart';

/// Accounts dashboard screen
/// 
/// Displays accounts-specific features including payment tracking,
/// financial reports, and approval workflows.
class AccountsDashboardScreen extends StatefulWidget {
  const AccountsDashboardScreen({super.key});

  @override
  State<AccountsDashboardScreen> createState() => _AccountsDashboardScreenState();
}

class _AccountsDashboardScreenState extends State<AccountsDashboardScreen> {
  late PaymentProvider _paymentProvider;

  @override
  void initState() {
    super.initState();
    _paymentProvider = getIt<PaymentProvider>();
    // Fetch pending challans count on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _paymentProvider.fetchPendingChallans();
      _paymentProvider.fetchPayments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts Dashboard'),
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: ChangeNotifierProvider.value(
        value: _paymentProvider,
        child: Consumer<PaymentProvider>(
          builder: (context, paymentProvider, child) {
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
                        user?.name ?? 'Accounts',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.role?.name ?? 'Accounts Manager',
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
                        title: 'All Challans',
                        description: 'View and filter challans',
                        icon: Icons.receipt_long,
                        iconColor: Colors.blue,
                        badgeCount: paymentProvider.pendingChallans.length,
                        onTap: () {
                          // Navigate to all challans screen
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChangeNotifierProvider.value(
                                value: _paymentProvider,
                                child: const AllChallansScreen(),
                              ),
                            ),
                          );
                        },
                      ),
                      DashboardCard(
                        title: 'Process Payment',
                        description: 'Record new payment',
                        icon: Icons.payment,
                        iconColor: Colors.green,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChangeNotifierProvider.value(
                                value: _paymentProvider,
                                child: const PaymentFormScreen(),
                              ),
                            ),
                          );
                        },
                      ),
                      DashboardCard(
                        title: 'Recent Payments',
                        description: 'View payment history',
                        icon: Icons.history,
                        iconColor: Colors.blue,
                        badgeCount: paymentProvider.payments.length,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Payment History - Coming Soon'),
                            ),
                          );
                        },
                      ),
                      DashboardCard(
                        title: 'Financial Reports',
                        description: 'Generate reports',
                        icon: Icons.assessment,
                        iconColor: Colors.purple,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Financial Reports - Coming Soon'),
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
              builder: (context) => ChangeNotifierProvider.value(
                value: _paymentProvider,
                child: const PaymentFormScreen(),
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Process Payment'),
      ),
    );
  }

  @override
  void dispose() {
    _paymentProvider.dispose();
    super.dispose();
  }
}
