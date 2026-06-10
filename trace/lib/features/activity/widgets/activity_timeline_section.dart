import 'package:flutter/material.dart';

import '../../../core/theme/trace_colors.dart';
import '../../../core/theme/trace_spacing.dart';
import '../../../core/theme/trace_typography.dart';
import '../domain/activity_event.dart';
import 'activity_journal_entry.dart';

class ActivityTimelineSection extends StatelessWidget {
  const ActivityTimelineSection({
    super.key,
    required this.period,
    required this.onEventTap,
  });

  final ActivityTimelinePeriod period;
  final ValueChanged<ActivityEvent> onEventTap;

  @override
  Widget build(BuildContext context) {
    if (period.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: TraceSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            period.label,
            style: TraceTypography.labelMMMono.copyWith(
              color: TraceColors.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: TraceSpacing.xs),
          ...period.events.map(
            (event) => ActivityJournalEntry(
              event: event,
              onTap: event.taskId == null ? null : () => onEventTap(event),
            ),
          ),
        ],
      ),
    );
  }
}
