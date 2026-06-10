import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_info.dart';
import '../../core/theme/trace_colors.dart';
import '../../core/theme/trace_spacing.dart';
import '../../core/theme/trace_typography.dart';
import '../../navigation/app_shell.dart';
import '../../shared/widgets/trace_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _titleOpacity;
  late final Animation<double> _taglineOpacity;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _logoScale = Tween<double>(begin: 0.88, end: 1).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0, 0.6, curve: Curves.easeOutCubic),
      ),
    );
    _logoOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0, 0.45, curve: Curves.easeOut),
    );
    _titleOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.35, 0.7, curve: Curves.easeOut),
    );
    _taglineOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
    );

    _introController.forward();
    _navigationTimer = Timer(const Duration(milliseconds: 2400), _goToTasks);
  }

  void _goToTasks() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AppShell(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TraceColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: TraceSpacing.containerPadding,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _logoOpacity,
                child: ScaleTransition(
                  scale: _logoScale,
                  child: const TraceLogo(size: 96),
                ),
              ),
              const SizedBox(height: TraceSpacing.lg),
              FadeTransition(
                opacity: _titleOpacity,
                child: Text(
                  'TRACE',
                  style: TraceTypography.displayLgMobile.copyWith(
                    letterSpacing: -1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: TraceSpacing.sm),
              FadeTransition(
                opacity: _taglineOpacity,
                child: Text(
                  AppInfo.tagline,
                  style: TraceTypography.bodyLg.copyWith(
                    color: TraceColors.secondary.withValues(alpha: 0.85),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
