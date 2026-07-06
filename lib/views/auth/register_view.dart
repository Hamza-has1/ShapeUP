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

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscureText = true;
  bool _obscureConfirmText = true;
  bool _agreeToTerms = false;
  String? _validationError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() async {
    setState(() {
      _validationError = null;
    });

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _validationError = 'All fields are required.';
      });
      return;
    }

    if (!email.contains('@')) {
      setState(() {
        _validationError = 'Please enter a valid email address.';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _validationError = 'Password must be at least 6 characters.';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _validationError = 'Passwords do not match.';
      });
      return;
    }

    if (!_agreeToTerms) {
      setState(() {
        _validationError = 'You must agree to the Terms & Conditions.';
      });
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      name: name,
      email: email,
      password: password,
    );

    if (success && mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
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
                      // Header
                      Text(
                        'Get Started',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ).animateEntrance(delayMs: 100),
                      const SizedBox(height: 8),
                      Text(
                        'Create an account to initialize customized plans.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ).animateEntrance(delayMs: 150),
                      
                      const SizedBox(height: 24),

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
                        const SizedBox(height: 16),
                      ],

                      // Form Container
                      GlassContainer(
                        opacity: isDark ? 0.05 : 0.03,
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          children: [
                            // Name
                            LuxuryTextField(
                              label: 'FULL NAME',
                              hint: 'Alex Mercer',
                              controller: _nameController,
                              prefixIcon: Icons.person_outline_rounded,
                            ),
                            const SizedBox(height: 16),

                            // Email
                            LuxuryTextField(
                              label: 'EMAIL ADDRESS',
                              hint: 'example@domain.com',
                              controller: _emailController,
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),

                            // Password
                            _buildPasswordField(
                              label: 'PASSWORD',
                              controller: _passwordController,
                              obscure: _obscureText,
                              onToggle: () => setState(() => _obscureText = !_obscureText),
                            ),
                            const SizedBox(height: 16),

                            // Confirm Password
                            _buildPasswordField(
                              label: 'CONFIRM PASSWORD',
                              controller: _confirmPasswordController,
                              obscure: _obscureConfirmText,
                              onToggle: () => setState(() => _obscureConfirmText = !_obscureConfirmText),
                            ),
                            const SizedBox(height: 16),

                            // Terms Agreement
                            Row(
                              children: [
                                Checkbox(
                                  value: _agreeToTerms,
                                  activeColor: AppColors.primaryPurple,
                                  onChanged: (val) {
                                    setState(() {
                                      _agreeToTerms = val ?? false;
                                    });
                                  },
                                ),
                                const Expanded(
                                  child: Text(
                                    'I agree to the Terms of Service & Privacy Policy',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Submit Button
                            if (auth.isLoading)
                              const LuxuryLoadingIndicator(message: 'Creating account...')
                            else
                              NeonGradientButton(
                                text: 'Sign Up',
                                onPressed: _onRegisterPressed,
                                icon: Icons.person_add_rounded,
                              ),
                          ],
                        ),
                      ).animateScaleEntrance(delayMs: 200),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account? '),
                          GestureDetector(
                            onTap: () {
                              context.push('/login');
                            },
                            child: const Text(
                              'Log In',
                              style: TextStyle(
                                color: AppColors.primaryPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ).animateEntrance(delayMs: 250),
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

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
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
            controller: controller,
            obscureText: obscure,
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: '••••••••',
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                ),
                onPressed: onToggle,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
