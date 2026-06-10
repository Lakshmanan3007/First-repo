import 'package:flutter/material.dart';

import '../../../core/theme/trace_colors.dart';
import '../../../core/theme/trace_spacing.dart';
import '../../../core/theme/trace_typography.dart';
import '../domain/activity_event.dart';

class ActivitySummaryCard extends StatelessWidget {
  const ActivitySummaryCard({super.key, required this.summary});

  final ActivityTodaySummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TraceSpacing.md),
      decoration: BoxDecoration(
        color: TraceColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(TraceSpacing.radiusLg),
        border: Border.all(
          color: TraceColors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Today's Summary", style: TraceTypography.titleS),
          const SizedBox(height: TraceSpacing.sm),
          Text(
            '${summary.currentCount} active • '
            '${summary.completedToday} completed • '
            '${summary.failedToday} failed • '
            '${summary.upcomingToday} upcoming',
            style: TraceTypography.bodyMd.copyWith(color: TraceColors.secondary),
          ),
        ],
      ),
    );
  }
}
