import 'package:flutter/material.dart';

import '../../../core/theme/trace_colors.dart';
import '../../../core/theme/trace_spacing.dart';
import '../../../core/theme/trace_typography.dart';

class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({
    super.key,
    this.showSkip = false,
    this.onSkip,
    this.trailing,
  });

  final bool showSkip;
  final VoidCallback? onSkip;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: TraceSpacing.containerPadding,
        vertical: TraceSpacing.sm,
      ),
      child: Row(
        children: [
          Text(
            'TRACE',
            style: TraceTypography.displayLgMobile.copyWith(
              fontSize: 28,
              letterSpacing: -1,
            ),
          ),
          const Spacer(),
          if (showSkip)
            TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(
                foregroundColor: TraceColors.secondary,
                padding: const EdgeInsets.symmetric(horizontal: TraceSpacing.sm),
              ),
              child: Text('Skip', style: TraceTypography.labelMd),
            )
          else
            ?trailing,
        ],
      ),
    );
  }
}
