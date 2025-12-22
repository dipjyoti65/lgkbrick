import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lgk_brick_managementapp/main.dart';
import '../../data/models/user.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart' hide LoginScreen;
import '../screens/admin_dashboard_screen.dart';
import '../screens/sales_dashboard_screen.dart';
import '../screens/logistics_dashboard_screen.dart';
import '../screens/accounts_dashboard_screen.dart';
import '../screens/requisition_form_screen.dart';
import '../screens/delivery_challan_form_screen.dart';
import '../screens/payment_form_screen.dart';

/// Application router configuration using GoRouter
/// 
/// Provides declarative routing with role-based route protection,
/// deep linking support, and navigation state management.
class AppRouter {
  /// Create GoRouter instance with authentication and role-based routing
  static GoRouter createRouter({
    required bool isAuthenticated,
    required User? currentUser,
    required bool isLoading,
  }) {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        // Show splash screen during initialization
        if (isLoading) {
          return '/';
        }

        final isOnLoginPage = state.matchedLocation == '/login';
        final isOnSplashPage = state.matchedLocation == '/';

        // Redirect to login if not authenticated
        if (!isAuthenticated) {
          return isOnLoginPage || isOnSplashPage ? null : '/login';
        }

        // Redirect to appropriate dashboard if authenticated and on login/splash
        if (isAuthenticated && (isOnLoginPage || isOnSplashPage)) {
          return _getDashboardRouteForRole(currentUser?.role?.name);
        }

        // Check role-based access for protected routes
        if (isAuthenticated && !_hasAccessToRoute(state.matchedLocation, currentUser)) {
          // Redirect to user's dashboard if they don't have access
          return _getDashboardRouteForRole(currentUser?.role?.name);
        }

        return null; // No redirect needed
      },
      routes: [
        // Splash Screen
        GoRoute(
          path: '/',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),

        // Login Screen
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),

        // Admin Routes
        GoRoute(
          path: '/admin',
          name: 'admin-dashboard',
          builder: (context, state) => const AdminDashboardScreen(),
        ),

        // Sales Routes
        GoRoute(
          path: '/sales',
          name: 'sales-dashboard',
          builder: (context, state) => const SalesDashboardScreen(),
          routes: [
            GoRoute(
              path: 'requisition/create',
              name: 'requisition-create',
              builder: (context, state) => const RequisitionFormScreen(),
            ),
          ],
        ),

        // Logistics Routes
        GoRoute(
          path: '/logistics',
          name: 'logistics-dashboard',
          builder: (context, state) => const LogisticsDashboardScreen(),
          routes: [
            GoRoute(
              path: 'challan/create',
              name: 'challan-create',
              builder: (context, state) => const DeliveryChallanFormScreen(),
            ),
          ],
        ),

        // Accounts Routes
        GoRoute(
          path: '/accounts',
          name: 'accounts-dashboard',
          builder: (context, state) => const AccountsDashboardScreen(),
          routes: [
            GoRoute(
              path: 'payment/create',
              name: 'payment-create',
              builder: (context, state) => const PaymentFormScreen(),
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Page Not Found',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'The page "${state.uri}" does not exist.',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get dashboard route based on user role
  static String _getDashboardRouteForRole(String? roleName) {
    switch (roleName?.toLowerCase()) {
      case 'admin':
        return '/admin';
      case 'sales':
      case 'sales executive':
        return '/sales';
      case 'logistics':
        return '/logistics';
      case 'accounts':
        return '/accounts';
      default:
        return '/admin'; // Default to admin dashboard
    }
  }

  /// Check if user has access to a specific route
  static bool _hasAccessToRoute(String route, User? user) {
    if (user == null) return false;

    final roleName = user.role?.name?.toLowerCase();

    // Define role-based route access
    final Map<String, List<String>> routeAccess = {
      '/admin': ['admin'],
      '/sales': ['sales', 'sales executive'],
      '/logistics': ['logistics'],
      '/accounts': ['accounts'],
    };

    // Check if route requires specific role
    for (final entry in routeAccess.entries) {
      if (route.startsWith(entry.key)) {
        return entry.value.contains(roleName);
      }
    }

    // Allow access to routes not in the map (public routes)
    return true;
  }
}

/// Extension methods for navigation
extension NavigationExtension on BuildContext {
  /// Navigate to admin dashboard
  void goToAdminDashboard() => go('/admin');

  /// Navigate to sales dashboard
  void goToSalesDashboard() => go('/sales');

  /// Navigate to logistics dashboard
  void goToLogisticsDashboard() => go('/logistics');

  /// Navigate to accounts dashboard
  void goToAccountsDashboard() => go('/accounts');

  /// Navigate to login screen
  void goToLogin() => go('/login');

  /// Navigate to requisition creation screen
  void goToRequisitionCreate() => go('/sales/requisition/create');

  /// Navigate to delivery challan creation screen
  void goToChallanCreate() => go('/logistics/challan/create');

  /// Navigate to payment processing screen
  void goToPaymentCreate() => go('/accounts/payment/create');
}
