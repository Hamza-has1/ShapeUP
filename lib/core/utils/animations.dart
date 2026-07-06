import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

extension ShapeUpAnimationExtension on Widget {
  Widget animateEntrance({
    Duration duration = const Duration(milliseconds: 600),
    double slideOffset = 30.0,
    double delayMs = 0,
  }) {
    return this
        .animate(delay: Duration(milliseconds: delayMs.toInt()))
        .fade(duration: duration, curve: Curves.easeOutCubic)
        .slideY(begin: slideOffset / 100, end: 0, duration: duration, curve: Curves.easeOutCubic);
  }

  Widget animateScaleEntrance({
    Duration duration = const Duration(milliseconds: 500),
    double delayMs = 0,
  }) {
    return this
        .animate(delay: Duration(milliseconds: delayMs.toInt()))
        .fade(duration: duration, curve: Curves.easeOutBack)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: duration, curve: Curves.easeOutBack);
  }

  Widget animateHoverEffect() {
    // Add simple scale dynamic feedback loop or standard animation behavior
    return this;
  }
}

class LuxuryPageTransition extends PageRouteBuilder {
  final Widget child;

  LuxuryPageTransition({required this.child})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: Curves.easeInOut),
            );
            final slideTween = Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).chain(
              CurveTween(curve: Curves.easeOutCubic),
            );

            return FadeTransition(
              opacity: animation.drive(fadeTween),
              child: SlideTransition(
                position: animation.drive(slideTween),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        );
}
