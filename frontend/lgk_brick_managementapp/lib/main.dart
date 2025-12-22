import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/di/service_locator.dart';
import 'business/providers/auth_provider.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/admin_dashboard_screen.dart';
import 'presentation/screens/sales_dashboard_screen.dart';
import 'presentation/screens/logistics_dashboard_screen.dart';
import 'presentation/screens/accounts_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize only essential services
    await setupServiceLocator();
    runApp(const MyApp());
  } catch (e) {
    // If initialization fails, show error
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Initialization failed: $e'),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<AuthProvider>(),
      child: MaterialApp(
        title: 'LGK Brick Management',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.initialize();
    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const SplashScreen();
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // If authenticated, navigate to appropriate dashboard
        if (authProvider.isAuthenticated) {
          final user = authProvider.currentUser;
          if (user?.role?.name == null) {
            return const LoginScreen();
          }
          
          switch (user!.role!.name.toLowerCase()) {
            case 'admin':
              return const AdminDashboardScreen();
            case 'sales executive':
              return const SalesDashboardScreen();
            case 'logistics':
              return const LogisticsDashboardScreen();
            case 'accounts':
              return const AccountsDashboardScreen();
            default:
              return const LoginScreen();
          }
        }
        
        // Not authenticated, show login screen
        return const LoginScreen();
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Add a minimum delay to show splash screen
      await Future.delayed(const Duration(seconds: 1));
      
      final authProvider = context.read<AuthProvider>();
      await authProvider.initialize();
      
      // Navigate to appropriate screen based on auth status
      if (mounted) {
        if (authProvider.isAuthenticated) {
          // Navigate to dashboard based on user role
          _navigateFromSplash(context, authProvider);
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      }
    } catch (e) {
      // If initialization fails, go to login after a short delay
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  void _navigateFromSplash(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.currentUser;
    if (user?.role?.name == null) {
      // If role is not available, go to login screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    Widget dashboardScreen;
    switch (user!.role!.name.toLowerCase()) {
      case 'admin':
        dashboardScreen = const AdminDashboardScreen();
        break;
      case 'sales executive':
        dashboardScreen = const SalesDashboardScreen();
        break;
      case 'logistics':
        dashboardScreen = const LogisticsDashboardScreen();
        break;
      case 'accounts':
        dashboardScreen = const AccountsDashboardScreen();
        break;
      default:
        // Unknown role, go to login screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
        return;
    }

    // Navigate to the appropriate dashboard
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => dashboardScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business,
              size: 100,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            const Text(
              'LGK Brick Management',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Initializing...'),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateToDashboard(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.currentUser;
    print('DEBUG: Current user: ${user?.name}');
    print('DEBUG: User role: ${user?.role?.name}');
    
    if (user?.role?.name == null) {
      // If role is not available, stay on login screen
      print('DEBUG: User role is null, staying on login screen');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to determine user role. Please try again.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Widget dashboardScreen;
    final roleName = user!.role!.name.toLowerCase();
    print('DEBUG: Role name (lowercase): $roleName');
    
    switch (roleName) {
      case 'admin':
        print('DEBUG: Navigating to Admin Dashboard');
        dashboardScreen = const AdminDashboardScreen();
        break;
      case 'sales executive':
        print('DEBUG: Navigating to Sales Dashboard');
        dashboardScreen = const SalesDashboardScreen();
        break;
      case 'logistics':
        print('DEBUG: Navigating to Logistics Dashboard');
        dashboardScreen = const LogisticsDashboardScreen();
        break;
      case 'accounts':
        print('DEBUG: Navigating to Accounts Dashboard');
        dashboardScreen = const AccountsDashboardScreen();
        break;
      default:
        // Unknown role, stay on login screen
        print('DEBUG: Unknown role: $roleName');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unknown user role: ${user.role!.name}'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
    }

    // Navigate to the appropriate dashboard
    print('DEBUG: About to navigate to dashboard');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => dashboardScreen),
    );
    print('DEBUG: Navigation completed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                Icon(
                  Icons.business,
                  size: 100,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),
                const Text(
                  'LGK Brick Management',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return Column(
                      children: [
                        if (authProvider.error != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error, color: Colors.red.shade700),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    authProvider.error!,
                                    style: TextStyle(color: Colors.red.shade700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ElevatedButton(
                          onPressed: authProvider.isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    print('DEBUG: Form validation passed');
                                    final success = await authProvider.login(
                                      _emailController.text.trim(),
                                      _passwordController.text,
                                    );
                                    
                                    print('DEBUG: Login success: $success');
                                    print('DEBUG: Widget mounted: $mounted');
                                    
                                    if (success && mounted) {
                                      print('DEBUG: About to show success snackbar and navigate');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Login successful!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      // Navigate to dashboard based on user role
                                      _navigateToDashboard(context, authProvider);
                                    } else {
                                      print('DEBUG: Navigation skipped - success: $success, mounted: $mounted');
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('Login'),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
