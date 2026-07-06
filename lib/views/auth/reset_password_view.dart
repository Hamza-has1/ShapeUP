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

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onReset() async {
    setState(() {
      _error = null;
      _isLoading = true;
    });

    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (password.isEmpty || confirm.isEmpty) {
      setState(() {
        _error = 'All fields are required.';
        _isLoading = false;
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _error = 'Password must be at least 6 characters.';
        _isLoading = false;
      });
      return;
    }

    if (password != confirm) {
      setState(() {
        _error = 'Passwords do not match.';
        _isLoading = false;
      });
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.resetPassword(password);

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully! Please login with your new password.'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/login');
    } else if (mounted) {
      setState(() {
        _error = auth.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Password'),
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
                        'Reset Password',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ).animateEntrance(delayMs: 100),
                      const SizedBox(height: 8),
                      Text(
                        'Set your new secure password.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ).animateEntrance(delayMs: 150),
                      
                      const SizedBox(height: 32),

                      if (_error != null) ...[
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
                                  _error!,
                                  style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ).animateScaleEntrance(),
                        const SizedBox(height: 20),
                      ],

                      // Form Card
                      GlassContainer(
                        opacity: isDark ? 0.05 : 0.03,
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          children: [
                            // Password
                            _buildPasswordField(
                              label: 'NEW PASSWORD',
                              controller: _passwordController,
                              obscure: _obscureText,
                              onToggle: () => setState(() => _obscureText = !_obscureText),
                            ),
                            const SizedBox(height: 16),

                            // Confirm Password
                            _buildPasswordField(
                              label: 'CONFIRM NEW PASSWORD',
                              controller: _confirmPasswordController,
                              obscure: _obscureText,
                              onToggle: () => setState(() => _obscureText = !_obscureText),
                            ),
                            const SizedBox(height: 24),

                            if (_isLoading)
                              const LuxuryLoadingIndicator(message: 'Updating password...')
                            else
                              NeonGradientButton(
                                text: 'Update Password',
                                onPressed: _onReset,
                                icon: Icons.lock_outline_rounded,
                              ),
                          ],
                        ),
                      ).animateScaleEntrance(delayMs: 200),
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
