import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/design_system.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/utils/animations.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: ResponsiveLayout.isMobile(context) ? 500 : 650,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Brand Logo
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: AppColors.purpleGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.bolt_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ).animateEntrance(delayMs: 100),

                      const SizedBox(height: 24),

                      // Welcome Headers
                      Text(
                        'ShapeUp',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 36,
                              color: AppColors.primaryPurple,
                            ),
                      ).animateEntrance(delayMs: 150),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        'Premium AI Wellness & Weight Loss',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        textAlign: TextAlign.center,
                      ).animateEntrance(delayMs: 200),

                      const SizedBox(height: 16),

                      Text(
                        'Your journey to a sustainable healthy lifestyle starts here. Realize customized fitness, active habit tracking, and personal evidence-based guidance from our AI specialists, Dr. Blue and Dr. Pink.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ).animateEntrance(delayMs: 250),

                      const SizedBox(height: 40),

                      // Glass Container buttons holder
                      GlassContainer(
                        opacity: isDark ? 0.05 : 0.03,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            NeonGradientButton(
                              text: 'Create Account',
                              onPressed: () {
                                context.push('/register');
                              },
                              icon: Icons.person_add_alt_1_rounded,
                            ),
                            const SizedBox(height: 16),
                            
                            // Log In Secondary Button
                            OutlinedButton(
                              onPressed: () {
                                context.push('/login');
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.primaryPurple, width: 2),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                minimumSize: const Size(double.infinity, 54),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                'Log In',
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      color: AppColors.primaryPurple,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ).animateScaleEntrance(delayMs: 300),

                      const SizedBox(height: 48),

                      // Terms and Privacy
                      Text(
                        'By continuing, you agree to our Terms of Service\nand Privacy Policy.',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
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
}
