import 'package:flutter/material.dart';

import '../../core/di/app_services.dart';
import '../../core/theme/trace_colors.dart';
import '../../core/theme/trace_spacing.dart';
import '../../core/theme/trace_typography.dart';
import '../../navigation/app_shell.dart';
import 'pages/get_started_onboarding_page.dart';
import 'pages/navigation_onboarding_page.dart';
import 'pages/philosophy_onboarding_page.dart';
import 'widgets/onboarding_header.dart';
import 'widgets/onboarding_progress.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  static const _stepLabels = [
    'Step 1 of 3: Core Philosophy',
    'Step 2 of 3: Navigation',
    'Step 3 of 3: Get Started',
  ];

  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await AppServices.instance.onboarding.markCompleted();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) => const AppShell(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _onContinue() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _onBack() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == 2;
    final isFirstPage = _currentPage == 0;

    return Scaffold(
      backgroundColor: TraceColors.background,
      body: SafeArea(
        child: Column(
          children: [
            OnboardingHeader(
              showSkip: isFirstPage,
              onSkip: _completeOnboarding,
              trailing: !isFirstPage
                  ? Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: TraceColors.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.more_vert,
                        size: 20,
                        color: TraceColors.secondary,
                      ),
                    )
                  : null,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: const [
                  PhilosophyOnboardingPage(),
                  NavigationOnboardingPage(),
                  GetStartedOnboardingPage(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _OnboardingFooter(
        currentPage: _currentPage,
        stepLabel: _stepLabels[_currentPage],
        isFirstPage: isFirstPage,
        isLastPage: isLastPage,
        onBack: _onBack,
        onContinue: _onContinue,
        onComplete: _completeOnboarding,
      ),
    );
  }
}

class _OnboardingFooter extends StatelessWidget {
  const _OnboardingFooter({
    required this.currentPage,
    required this.stepLabel,
    required this.isFirstPage,
    required this.isLastPage,
    required this.onBack,
    required this.onContinue,
    required this.onComplete,
  });

  final int currentPage;
  final String stepLabel;
  final bool isFirstPage;
  final bool isLastPage;
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    if (isLastPage) {
      return Container(
        padding: EdgeInsets.fromLTRB(
          TraceSpacing.gutter,
          TraceSpacing.lg,
          TraceSpacing.gutter,
          TraceSpacing.lg + MediaQuery.paddingOf(context).bottom,
        ),
        decoration: BoxDecoration(
          color: TraceColors.background,
          border: Border(
            top: BorderSide(
              color: TraceColors.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OnboardingProgress(
              currentStep: currentPage,
              totalSteps: 3,
              compact: true,
            ),
            const SizedBox(height: TraceSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onComplete,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: TraceSpacing.lg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(TraceSpacing.radiusXl),
                  ),
                ),
                child: Text(
                  'Begin Using TRACE',
                  style: TraceTypography.headlineSm.copyWith(
                    color: TraceColors.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: TraceSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'QUICK SEARCH',
                  style: TraceTypography.labelSMono,
                ),
                const SizedBox(width: TraceSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: TraceColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(TraceSpacing.radiusDefault),
                    border: Border.all(color: TraceColors.outlineVariant),
                  ),
                  child: Text(
                    'CMD + K',
                    style: TraceTypography.labelSMono.copyWith(fontSize: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (currentPage == 1) {
      return Container(
        padding: EdgeInsets.fromLTRB(
          TraceSpacing.gutter,
          TraceSpacing.md,
          TraceSpacing.gutter,
          TraceSpacing.md + MediaQuery.paddingOf(context).bottom,
        ),
        decoration: BoxDecoration(
          color: TraceColors.surfaceContainerLowest.withValues(alpha: 0.7),
          border: Border(
            top: BorderSide(
              color: TraceColors.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
        ),
        child: Row(
          children: [
            TextButton(
              onPressed: onBack,
              child: Text(
                'BACK',
                style: TraceTypography.labelMMMono.copyWith(
                  letterSpacing: 1.5,
                  color: TraceColors.secondary,
                ),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: TraceSpacing.md),
                ),
                child: Text(
                  'INITIALIZE SYSTEM',
                  style: TraceTypography.labelMMMono.copyWith(
                    color: TraceColors.onPrimary,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Step 1 footer
    return Container(
      padding: EdgeInsets.fromLTRB(
        TraceSpacing.containerPadding,
        TraceSpacing.lg,
        TraceSpacing.containerPadding,
        TraceSpacing.xl + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            TraceColors.background,
            TraceColors.background.withValues(alpha: 0.95),
            TraceColors.background.withValues(alpha: 0),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OnboardingProgress(currentStep: currentPage, totalSteps: 3),
          const SizedBox(height: TraceSpacing.md),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onContinue,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Continue', style: TraceTypography.headlineSm.copyWith(
                    color: TraceColors.onPrimary,
                  )),
                  const SizedBox(width: TraceSpacing.sm),
                  const Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: TraceSpacing.md),
          Text(
            stepLabel,
            style: TraceTypography.labelMd.copyWith(
              color: TraceColors.secondary.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
