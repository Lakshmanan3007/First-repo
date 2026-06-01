import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/trace_colors.dart';
import '../../core/theme/trace_spacing.dart';
import '../../core/theme/trace_typography.dart';
import '../../core/di/app_services.dart';
import '../../features/onboarding/onboarding_flow.dart';
import '../../navigation/app_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _progressController;
  late final AnimationController _letterSpacingController;

  late final Animation<double> _logoFade;
  late final Animation<double> _taglineFade;
  late final Animation<double> _indicatorFade;
  late final Animation<double> _metadataFade;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _letterSpacingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _logoFade = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0, 0.35, curve: Curves.easeOutCubic),
    );
    _taglineFade = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.25, 0.55, curve: Curves.easeOutCubic),
    );
    _indicatorFade = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.5, 0.8, curve: Curves.easeOutCubic),
    );
    _metadataFade = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.75, 1, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    Future<void>.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _letterSpacingController.forward();
    });

    _navigationTimer = Timer(const Duration(milliseconds: 2800), _goToNextScreen);
  }

  void _goToNextScreen() {
    if (!mounted) return;
    final completed = AppServices.instance.onboarding.isCompleted;
    final destination =
        completed ? const AppShell() : const OnboardingFlow();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _fadeController.dispose();
    _progressController.dispose();
    _letterSpacingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TraceColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: _DotPatternBackground()),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: TraceSpacing.containerPadding,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FadeTransition(
                            opacity: _logoFade,
                            child: AnimatedBuilder(
                              animation: _letterSpacingController,
                              builder: (context, child) {
                                final spacing = Tween<double>(
                                  begin: -3.2,
                                  end: -1.4,
                                ).evaluate(_letterSpacingController);
                                return Text(
                                  'TRACE',
                                  style: TraceTypography.displayLg.copyWith(
                                    fontSize: 64,
                                    height: 1,
                                    letterSpacing: spacing,
                                  ),
                                  textAlign: TextAlign.center,
                                );
                              },
                            ),
                          ),
                          FadeTransition(
                            opacity: _taglineFade,
                            child: Padding(
                              padding: const EdgeInsets.only(top: TraceSpacing.unit),
                              child: Text(
                                '“Every Task Leaves a Trace.”',
                                style: TraceTypography.bodyLg.copyWith(
                                  color: TraceColors.secondary.withValues(alpha: 0.8),
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          FadeTransition(
                            opacity: _indicatorFade,
                            child: Padding(
                              padding: const EdgeInsets.only(top: TraceSpacing.xl),
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: 160,
                                    height: 1.5,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(1),
                                      child: ColoredBox(
                                        color: TraceColors.outlineVariant.withValues(alpha: 0.4),
                                        child: AnimatedBuilder(
                                          animation: _progressController,
                                          builder: (context, _) {
                                            return Align(
                                              alignment: Alignment(
                                                -1 + 3 * _progressController.value,
                                                0,
                                              ),
                                              child: Container(
                                                width: 53,
                                                height: 1.5,
                                                color: TraceColors.primary,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: TraceSpacing.lg),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'INITIALIZING CORE',
                                        style: TraceTypography.labelCaps.copyWith(
                                          fontSize: 10,
                                          letterSpacing: 2,
                                          color: TraceColors.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(width: TraceSpacing.sm),
                                      const _PulsingDot(delay: 0),
                                      const _PulsingDot(delay: 150),
                                      const _PulsingDot(delay: 300),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                FadeTransition(
                  opacity: _metadataFade,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: TraceSpacing.xl),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: TraceSpacing.lg,
                        vertical: TraceSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: TraceColors.surfaceContainerLow.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: TraceColors.outlineVariant.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            size: 16,
                            color: TraceColors.secondary,
                          ),
                          const SizedBox(width: TraceSpacing.sm),
                          Text(
                            'V. 2.4.0 OPERATIONAL',
                            style: TraceTypography.labelCaps.copyWith(
                              fontSize: 10,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w600,
                              color: TraceColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DotPatternBackground extends StatelessWidget {
  const _DotPatternBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.15,
        child: CustomPaint(
          painter: _DotPatternPainter(),
        ),
      ),
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 32.0;
    final paint = Paint()..color = TraceColors.primary;

    for (var x = 0.0; x < size.width; x += spacing) {
      for (var y = 0.0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.75, paint);
      }
    }

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        TraceColors.background.withValues(alpha: 0.2),
        TraceColors.background,
      ],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = gradient.createShader(
          Rect.fromLTWH(0, 0, size.width, size.height),
        ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.delay});

  final int delay;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    Future<void>.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 1).animate(_controller),
      child: Container(
        width: 4,
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 1.5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: TraceColors.primary.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
