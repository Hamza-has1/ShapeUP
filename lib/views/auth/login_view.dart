import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/design_system.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/utils/animations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_state.dart';
import '../../providers/profile_provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _rememberMe = false;
  String? _validationError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() async {
    setState(() {
      _validationError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _validationError = 'Please fill out all fields.';
      });
      return;
    }

    if (!email.contains('@')) {
      setState(() {
        _validationError = 'Please enter a valid email address.';
      });
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(email, password, _rememberMe);
    
    if (success && mounted) {
      final appState = context.read<AppStateProvider>();
      final profileState = context.read<ProfileProvider>();
      await appState.syncFromProfile();
      await profileState.reloadProfile();
      if (mounted) {
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log In'),
      ),
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: isDark ? AppColors.luxuryDarkGradient : AppColors.luxuryLightGradient,
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: ResponsiveLayout.isMobile(context) ? 460 : 580,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Form Header
                      Text(
                        'Welcome Back',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ).animateEntrance(delayMs: 100),
                      const SizedBox(height: 8),
                      Text(
                        'Access your personalized wellness profile.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ).animateEntrance(delayMs: 150),
                      
                      const SizedBox(height: 32),

                      // Errors display
                      if (_validationError != null || auth.error != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            border: Border.all(color: AppColors.error),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: AppColors.error),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _validationError ?? auth.error!,
                                  style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ).animateScaleEntrance(),
                        const SizedBox(height: 20),
                      ],

                      // Form Container
                      GlassContainer(
                        opacity: isDark ? 0.05 : 0.03,
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          children: [
                            // Email
                            LuxuryTextField(
                              label: 'EMAIL ADDRESS',
                              hint: 'example@domain.com',
                              controller: _emailController,
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 20),

                            // Password
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                                  child: Text(
                                    'PASSWORD',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                  ),
                                ),
                                GlassContainer(
                                  opacity: isDark ? 0.08 : 0.04,
                                  borderRadius: BorderRadius.circular(16),
                                  child: TextField(
                                    controller: _passwordController,
                                    obscureText: _obscureText,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                    decoration: InputDecoration(
                                      hintText: 'Enter password',
                                      prefixIcon: Icon(
                                        Icons.lock_outline_rounded,
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureText = !_obscureText;
                                          });
                                        },
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Remember Me & Forgot Password Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      activeColor: AppColors.primaryPurple,
                                      onChanged: (val) {
                                        setState(() {
                                          _rememberMe = val ?? false;
                                        });
                                      },
                                    ),
                                    const Text('Remember Me', style: TextStyle(fontSize: 13)),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {
                                    context.push('/forgot-password');
                                  },
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: AppColors.primaryPurple,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Submit Button or Loading state
                            if (auth.isLoading)
                              const LuxuryLoadingIndicator(message: 'Authenticating session...')
                            else
                              NeonGradientButton(
                                text: 'Log In',
                                onPressed: _onLoginPressed,
                                icon: Icons.login_rounded,
                              ),
                          ],
                        ),
                      ).animateScaleEntrance(delayMs: 200),
                      
                      const SizedBox(height: 32),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Don\'t have an account? '),
                          GestureDetector(
                            onTap: () {
                              context.push('/register');
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: AppColors.primaryPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ).animateEntrance(delayMs: 350),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: GlassContainer(
          opacity: 0.05,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
