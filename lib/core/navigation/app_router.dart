import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../providers/auth_provider.dart';
import '../../views/dashboard/dashboard_view.dart';
import '../../views/onboarding/onboarding_view.dart';
import '../../views/coaches/coaches_view.dart';
import '../../views/auth/splash_view.dart';
import '../../views/auth/welcome_view.dart';
import '../../views/auth/login_view.dart';
import '../../views/auth/register_view.dart';
import '../../views/auth/forgot_password_view.dart';
import '../../views/auth/otp_verification_view.dart';
import '../../views/auth/reset_password_view.dart';

class AppRouter {
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otp = '/otp';
  static const String resetPassword = '/reset-password';
  static const String dashboard = '/';
  static const String onboarding = '/onboarding';
  static const String coaches = '/coaches';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: welcome,
        name: 'welcome',
        builder: (context, state) => const WelcomeView(),
      ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => const RegisterView(),
      ),
      GoRoute(
        path: forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordView(),
      ),
      GoRoute(
        path: otp,
        name: 'otp',
        builder: (context, state) => const OtpVerificationView(),
      ),
      GoRoute(
        path: resetPassword,
        name: 'reset-password',
        builder: (context, state) => const ResetPasswordView(),
      ),
      GoRoute(
        path: onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingView(),
      ),
      GoRoute(
        path: dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardView(),
      ),
      GoRoute(
        path: coaches,
        name: 'coaches',
        builder: (context, state) => const CoachesView(),
      ),
    ],
    redirect: (context, state) {
      final auth = context.read<AuthProvider>();
      final isLoggingIn = state.matchedLocation == login ||
          state.matchedLocation == register ||
          state.matchedLocation == welcome ||
          state.matchedLocation == splash ||
          state.matchedLocation == forgotPassword ||
          state.matchedLocation == otp ||
          state.matchedLocation == resetPassword;

      if (auth.status == AuthStatus.uninitialized) {
        return splash;
      }

      if (auth.status == AuthStatus.unauthenticated && !isLoggingIn) {
        return welcome;
      }

      if (auth.status == AuthStatus.authenticated && isLoggingIn) {
        final appState = context.read<AppStateProvider>();
        return appState.isOnboarded ? dashboard : onboarding;
      }

      return null;
    },
  );
}
