import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business/providers/auth_provider.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/responsive_utils.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/message_display.dart';
import '../widgets/adaptive_layout.dart';
import '../widgets/responsive_form_field.dart';

/// Login screen with email and password authentication
/// 
/// Provides a form for users to enter their credentials and authenticate
/// with the backend API. Includes form validation, loading states, and
/// error handling.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Clear any previous errors
    context.read<AuthProvider>().clearError();

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Attempt login
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      // Navigation will be handled by the app's root widget
      // based on authentication state
    } else {
      // Error message is already set in the provider
      // and will be displayed in the UI
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AdaptiveLayout(
          child: SingleChildScrollView(
            child: AdaptiveFormLayout(
              wrapInCard: ResponsiveUtils.isTablet(context) || ResponsiveUtils.isDesktop(context),
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // App Logo/Title
                      Icon(
                        Icons.business,
                        size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 80),
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),
                      Text(
                        'LGK Brick Management',
                        style: AppTextStyles.h1.copyWith(
                          fontSize: (AppTextStyles.h1.fontSize ?? 32) *
                              ResponsiveUtils.getFontSizeMultiplier(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 8)),
                      Text(
                        'Sign in to continue',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.grey[600],
                          fontSize: (AppTextStyles.bodyMedium.fontSize ?? 16) *
                              ResponsiveUtils.getFontSizeMultiplier(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 48)),

                      // Email Field
                      ResponsiveTextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        validator: Validators.email,
                        enabled: !context.watch<AuthProvider>().isLoading,
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsiveFormSpacing(context)),

                      // Password Field
                      ResponsiveTextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleLogin(),
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: Validators.password,
                        enabled: !context.watch<AuthProvider>().isLoading,
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 24)),

                      // Error Message
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          if (authProvider.error != null) {
                            return MessageDisplay.error(
                              authProvider.error!,
                              onDismiss: () => authProvider.clearError(),
                              margin: EdgeInsets.only(
                                bottom: ResponsiveUtils.getResponsiveSpacing(context),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      // Login Button
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return ResponsiveButton(
                            isLoading: authProvider.isLoading,
                            onPressed: _handleLogin,
                            loadingText: 'Signing in...',
                            fullWidth: true,
                            child: const Text('Sign In'),
                          );
                        },
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 24)),

                      // Additional Info
                      Text(
                        'Contact your administrator for login credentials',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.grey[600],
                          fontSize: (AppTextStyles.bodySmall.fontSize ?? 14) *
                              ResponsiveUtils.getFontSizeMultiplier(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
