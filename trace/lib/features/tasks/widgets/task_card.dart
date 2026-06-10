import 'package:flutter/material.dart';

import '../../../core/theme/trace_colors.dart';
import '../../../core/theme/trace_spacing.dart';
import '../../../core/theme/trace_typography.dart';
import '../domain/task.dart';
import '../utils/task_display_format.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
  });

  final Task task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final indicatorColor = TaskDisplayFormat.indicatorColor(task);
    final urgent = TaskDisplayFormat.timeIsUrgent(task);

    return Material(
      color: TraceColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(TraceSpacing.radiusXl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TraceSpacing.radiusXl),
        child: Container(
          padding: const EdgeInsets.all(TraceSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TraceSpacing.radiusXl),
            border: Border.all(
              color: TraceColors.outlineVariant.withValues(alpha: 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: TraceColors.primary.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 2,
                height: 72,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(width: TraceSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            task.name,
                            style: TraceTypography.titleS.copyWith(
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: TraceSpacing.sm),
                        Text(
                          task.priority.dashboardLabel,
                          style: TraceTypography.labelSMono.copyWith(
                            fontWeight: FontWeight.bold,
                            color: TaskDisplayFormat.priorityTextColor(task),
                          ),
                        ),
                      ],
                    ),
                    if (task.description != null &&
                        task.description!.isNotEmpty) ...[
                      const SizedBox(height: TraceSpacing.xs),
                      Text(
                        task.description!,
                        style: TraceTypography.bodyMd.copyWith(
                          fontSize: 13,
                          color: TraceColors.secondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: TraceSpacing.sm),
                    Row(
                      children: [
                        Icon(
                          TaskDisplayFormat.timeIcon(task),
                          size: 14,
                          color: urgent
                              ? TraceColors.error
                              : TraceColors.onSurface,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          TaskDisplayFormat.timeLabel(task),
                          style: TraceTypography.labelMMMono.copyWith(
                            fontSize: 11,
                            color: urgent
                                ? TraceColors.error
                                : TraceColors.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: TraceSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: TraceColors.surfaceContainer,
                            borderRadius:
                                BorderRadius.circular(TraceSpacing.radiusDefault),
                          ),
                          child: Text(
                            TaskDisplayFormat.projectTag(task),
                            style: TraceTypography.labelSMono.copyWith(
                              color: TraceColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
