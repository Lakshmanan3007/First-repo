import 'package:flutter/material.dart';

import '../../../core/theme/trace_colors.dart';
import '../../../core/theme/trace_spacing.dart';

class OnboardingProgress extends StatelessWidget {
  const OnboardingProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.compact = false,
  });

  final int currentStep;
  final int totalSteps;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index == currentStep;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: isActive ? (compact ? 40 : 32) : (compact ? 24 : 8),
          height: compact ? 4 : 4,
          decoration: BoxDecoration(
            color: isActive
                ? TraceColors.primary
                : TraceColors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(TraceSpacing.radiusDefault),
          ),
        );
      }),
    );
  }
}
