import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/trace_colors.dart';
import '../../../core/theme/trace_spacing.dart';
import '../../../core/theme/trace_typography.dart';
import '../domain/activity_event.dart';
import 'activity_journal_item.dart';

class ActivityDaySection extends StatelessWidget {
  const ActivityDaySection({
    super.key,
    required this.group,
    required this.muted,
    required this.onEventTap,
  });

  final ActivityDayGroup group;
  final bool muted;
  final ValueChanged<ActivityEvent> onEventTap;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('d MMM').format(group.day).toUpperCase();
    final headerLabel = group.isToday ? 'MEM_BLOCK_TODAY' : 'MEM_BLOCK_PREV';

    return Opacity(
      opacity: muted ? 0.7 : 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                headerLabel,
                style: TraceTypography.labelMMMono.copyWith(
                  fontWeight: FontWeight.bold,
                  color: group.isToday
                      ? TraceColors.primary
                      : TraceColors.secondary,
                ),
              ),
              const SizedBox(width: TraceSpacing.sm),
              Text(
                '/ $dateLabel',
                style: TraceTypography.labelSMono.copyWith(
                  color: TraceColors.outline,
                ),
              ),
              const SizedBox(width: TraceSpacing.sm),
              Expanded(
                child: Container(
                  height: 1,
                  color: group.isToday
                      ? TraceColors.primary.withValues(alpha: 0.1)
                      : TraceColors.surfaceContainerHigh,
                ),
              ),
            ],
          ),
          const SizedBox(height: TraceSpacing.lg),
          if (group.events.isEmpty)
            Text(
              'No operational events recorded.',
              style: TraceTypography.bodyMd.copyWith(color: TraceColors.secondary),
            )
          else
            ...List.generate(group.events.length, (index) {
              final event = group.events[index];
              return ActivityJournalItem(
                event: event,
                isLast: index == group.events.length - 1,
                onTap: event.taskId != null
                    ? () => onEventTap(event)
                    : null,
              );
            }),
          const SizedBox(height: TraceSpacing.xl),
        ],
      ),
    );
  }
}
