import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_state.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Simulate splash presentation & framework loading
    await Future.delayed(const Duration(milliseconds: 2000));
    
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    final appState = context.read<AppStateProvider>();

    // Route logic based on auth status and onboarding status
    if (auth.status == AuthStatus.authenticated) {
      if (appState.isOnboarded) {
        context.go('/');
      } else {
        context.go('/onboarding');
      }
    } else {
      context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.luxuryDarkGradient : AppColors.luxuryLightGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.purpleGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPurple.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: Colors.white,
                  size: 64,
                ),
              )
                  .animate()
                  .fade(duration: 800.ms, curve: Curves.easeOut)
                  .scale(begin: const Offset(0.7, 0.7), end: const Offset(1, 1), duration: 800.ms, curve: Curves.elasticOut),

              const SizedBox(height: 24),

              // Title
              Text(
                'ShapeUp',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
              )
                  .animate()
                  .fade(delay: 200.ms, duration: 600.ms)
                  .slideY(begin: 0.2, end: 0, duration: 600.ms),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                'AI Weight Loss & Wellness',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
              )
                  .animate()
                  .fade(delay: 400.ms, duration: 600.ms),

              const SizedBox(height: 48),

              // Simple Loading indicator
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? Colors.white70 : AppColors.primaryPurple,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
