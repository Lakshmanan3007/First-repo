import 'package:flutter/material.dart';

import '../../../core/theme/trace_colors.dart';
import '../../../core/theme/trace_spacing.dart';
import '../../../core/theme/trace_typography.dart';
import '../domain/task_status.dart';

class TaskSummaryStrip extends StatelessWidget {
  const TaskSummaryStrip({
    super.key,
    required this.counts,
    required this.onStatusTap,
  });

  final Map<TaskStatus, int> counts;
  final ValueChanged<TaskStatus> onStatusTap;

  @override
  Widget build(BuildContext context) {
    final segments = TaskStatus.tabOrder.map((status) {
      return _SummarySegment(
        label: '${counts[status] ?? 0} ${status.summaryLabel}',
        onTap: () => onStatusTap(status),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TraceSpacing.marginMobile,
        0,
        TraceSpacing.marginMobile,
        TraceSpacing.sm,
      ),
      child: Material(
        color: TraceColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(TraceSpacing.radiusLg),
        child: InkWell(
          borderRadius: BorderRadius.circular(TraceSpacing.radiusLg),
          onTap: null,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: TraceSpacing.md,
              vertical: TraceSpacing.sm,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < segments.length; i++) ...[
                    if (i > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: TraceSpacing.sm,
                        ),
                        child: Text(
                          '•',
                          style: TraceTypography.bodyMd.copyWith(
                            color: TraceColors.secondary.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    segments[i],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummarySegment extends StatelessWidget {
  const _SummarySegment({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(TraceSpacing.radiusDefault),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TraceSpacing.xs,
          vertical: 2,
        ),
        child: Text(
          label,
          style: TraceTypography.labelMMMono.copyWith(
            fontSize: 12,
            color: TraceColors.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
