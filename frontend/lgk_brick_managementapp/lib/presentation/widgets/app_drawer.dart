import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../business/providers/auth_provider.dart';
import '../../core/utils/responsive_utils.dart';
import '../../data/models/user.dart';
import '../screens/login_screen.dart';
import 'role_based_widget.dart';
import 'enhanced_navigation.dart';
import 'visual_feedback.dart';
import 'feedback_manager.dart';

/// Application drawer with role-based navigation
/// 
/// Provides a navigation drawer that adapts its menu items
/// based on the current user's role and permissions with enhanced
/// visual feedback and responsive design.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return EnhancedDrawer(
      header: _buildDrawerHeader(context, user),
      children: [
        // Admin Navigation Items
        AdminOnlyWidget(
          child: Column(
            children: [
              _buildNavItem(
                context,
                icon: Icons.dashboard,
                title: 'Dashboard',
                onTap: () {
                  context.go('/admin');
                  Navigator.pop(context);
                },
              ),
              _buildNavItem(
                context,
                icon: Icons.people,
                title: 'User Management',
                onTap: () {
                  // TODO: Navigate to user management
                  Navigator.pop(context);
                },
              ),
              _buildNavItem(
                context,
                icon: Icons.category,
                title: 'Brick Types',
                onTap: () {
                  // TODO: Navigate to brick type management
                  Navigator.pop(context);
                },
              ),
              _buildDivider(context),
            ],
          ),
        ),

        // Sales Navigation Items
        SalesOnlyWidget(
          child: Column(
            children: [
              _buildNavItem(
                context,
                icon: Icons.dashboard,
                title: 'Dashboard',
                onTap: () {
                  context.go('/sales');
                  Navigator.pop(context);
                },
              ),
              _buildNavItem(
                context,
                icon: Icons.add_shopping_cart,
                title: 'Create Requisition',
                onTap: () {
                  context.go('/requisition/create');
                  Navigator.pop(context);
                },
              ),
              _buildNavItem(
                context,
                icon: Icons.list_alt,
                title: 'My Requisitions',
                onTap: () {
                  // TODO: Navigate to requisitions list
                  Navigator.pop(context);
                },
              ),
              _buildDivider(context),
            ],
          ),
        ),

        // Logistics Navigation Items
        LogisticsOnlyWidget(
          child: Column(
            children: [
              _buildNavItem(
                context,
                icon: Icons.dashboard,
                title: 'Dashboard',
                onTap: () {
                  context.go('/logistics');
                  Navigator.pop(context);
                },
              ),
              _buildNavItem(
                context,
                icon: Icons.local_shipping,
                title: 'Create Delivery Challan',
                onTap: () {
                  context.go('/challan/create');
                  Navigator.pop(context);
                },
              ),
              _buildNavItem(
                context,
                icon: Icons.assignment,
                title: 'Delivery Challans',
                onTap: () {
                  // TODO: Navigate to challans list
                  Navigator.pop(context);
                },
              ),
              _buildDivider(context),
            ],
          ),
        ),

        // Accounts Navigation Items
        AccountsOnlyWidget(
          child: Column(
            children: [
              _buildNavItem(
                context,
                icon: Icons.dashboard,
                title: 'Dashboard',
                onTap: () {
                  context.go('/accounts');
                  Navigator.pop(context);
                },
              ),
              _buildNavItem(
                context,
                icon: Icons.payment,
                title: 'Process Payment',
                onTap: () {
                  context.go('/payment/create');
                  Navigator.pop(context);
                },
              ),
              _buildNavItem(
                context,
                icon: Icons.receipt_long,
                title: 'Payment Records',
                onTap: () {
                  // TODO: Navigate to payments list
                  Navigator.pop(context);
                },
              ),
              _buildNavItem(
                context,
                icon: Icons.analytics,
                title: 'Reports',
                onTap: () {
                  // TODO: Navigate to reports
                  Navigator.pop(context);
                },
              ),
              _buildDivider(context),
            ],
          ),
        ),

        // Common Navigation Items
        _buildNavItem(
          context,
          icon: Icons.settings,
          title: 'Settings',
          onTap: () {
            // TODO: Navigate to settings
            Navigator.pop(context);
          },
        ),
        _buildNavItem(
          context,
          icon: Icons.help_outline,
          title: 'Help & Support',
          onTap: () {
            // TODO: Navigate to help
            Navigator.pop(context);
          },
        ),
        
        _buildDivider(context),
        
        // Logout
        _buildNavItem(
          context,
          icon: Icons.logout,
          title: 'Logout',
          textColor: Colors.red.shade600,
          iconColor: Colors.red.shade600,
          onTap: () => _handleLogout(context, authProvider),
        ),
      ],
    );
  }

  Widget _buildDrawerHeader(BuildContext context, User? user) {
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      currentAccountPicture: RippleEffect(
        borderRadius: BorderRadius.circular(50),
        onTap: () {
          // TODO: Navigate to profile
        },
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: Text(
            user?.name?.substring(0, 1).toUpperCase() ?? 'U',
            style: TextStyle(
              fontSize: 32 * ResponsiveUtils.getFontSizeMultiplier(context),
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      accountName: Text(
        user?.name ?? 'User',
        style: TextStyle(
          fontSize: 18 * ResponsiveUtils.getFontSizeMultiplier(context),
          fontWeight: FontWeight.bold,
        ),
      ),
      accountEmail: Text(
        user?.email ?? '',
        style: TextStyle(
          fontSize: 14 * ResponsiveUtils.getFontSizeMultiplier(context),
        ),
      ),
      otherAccountsPictures: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white),
          onPressed: () {
            // TODO: Navigate to profile edit
          },
          tooltip: 'Edit Profile',
        ),
      ],
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return RippleEffect(
      onTap: () {
        AppHapticFeedback.selectionClick();
        onTap();
      },
      child: EnhancedListTile(
        leading: Icon(
          icon,
          color: iconColor ?? Theme.of(context).iconTheme.color,
          size: ResponsiveUtils.getResponsiveIconSize(context),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: (Theme.of(context).textTheme.bodyLarge?.fontSize ?? 16) *
                ResponsiveUtils.getFontSizeMultiplier(context),
          ),
        ),
        onTap: onTap,
        contentPadding: ResponsiveUtils.getResponsiveListTilePadding(context),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: ResponsiveUtils.getResponsiveVerticalPadding(context).copyWith(
        top: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 8),
        bottom: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 8),
      ),
      child: const Divider(),
    );
  }

  Future<void> _handleLogout(BuildContext context, AuthProvider authProvider) async {
    final confirmed = await FeedbackManager.showLogoutConfirmation(context);
    
    if (confirmed) {
      AppHapticFeedback.mediumImpact();
      
      // Show loading feedback
      context.showLoading('Signing out...');
      
      try {
        await authProvider.logout();
        
        if (context.mounted) {
          context.showSuccess('Signed out successfully');
          // Navigate to login screen and clear all previous routes
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          context.showError('Failed to sign out: ${e.toString()}');
        }
      }
    }
  }
}