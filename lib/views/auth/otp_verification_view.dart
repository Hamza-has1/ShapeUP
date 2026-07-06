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

class OtpVerificationView extends StatefulWidget {
  const OtpVerificationView({super.key});

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _onVerify() async {
    setState(() {
      _error = null;
      _isLoading = true;
    });

    final otp = _otpController.text.trim();
    if (otp.length != 4) {
      setState(() {
        _error = 'Please enter a 4-digit code.';
        _isLoading = false;
      });
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.verifyOtp(otp);

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      context.push('/reset-password');
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
        title: const Text('Verify OTP'),
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
                        'Verification Code',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ).animateEntrance(delayMs: 100),
                      const SizedBox(height: 8),
                      Text(
                        'Enter the 4-digit code sent to your email. (Use "1234")',
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
                            LuxuryTextField(
                              label: '4-DIGIT CODE',
                              hint: '1234',
                              controller: _otpController,
                              prefixIcon: Icons.lock_open_rounded,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 24),
                            if (_isLoading)
                              const LuxuryLoadingIndicator(message: 'Verifying code...')
                            else
                              NeonGradientButton(
                                text: 'Verify & Continue',
                                onPressed: _onVerify,
                                icon: Icons.verified_user_rounded,
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
}
