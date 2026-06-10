import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/trace_colors.dart';
import '../../../core/theme/trace_spacing.dart';
import '../../../core/theme/trace_typography.dart';
import '../domain/activity_event.dart';

class ActivityTransitionsSection extends StatelessWidget {
  const ActivityTransitionsSection({
    super.key,
    required this.transitions,
    required this.onTap,
  });

  final List<ActivityTransition> transitions;
  final ValueChanged<ActivityTransition> onTap;

  static final _format = DateFormat('MMM d • h:mm a');

  @override
  Widget build(BuildContext context) {
    if (transitions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: TraceSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Upcoming Transitions', style: TraceTypography.titleS),
          const SizedBox(height: TraceSpacing.sm),
          ...transitions.map(
            (transition) => Material(
              color: TraceColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(TraceSpacing.radiusLg),
              child: InkWell(
                onTap: () => onTap(transition),
                borderRadius: BorderRadius.circular(TraceSpacing.radiusLg),
                child: Container(
                  margin: const EdgeInsets.only(bottom: TraceSpacing.xs),
                  padding: const EdgeInsets.all(TraceSpacing.md),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(TraceSpacing.radiusLg),
                    border: Border.all(
                      color: TraceColors.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text('→', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: TraceSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(transition.taskName, style: TraceTypography.bodyMd),
                            Text(
                              '${transition.label} • ${_format.format(transition.at)}',
                              style: TraceTypography.labelSMono.copyWith(
                                color: TraceColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
