import 'package:flutter/material.dart';

import '../../../core/theme/trace_colors.dart';
import '../../../core/theme/trace_spacing.dart';
import '../../../core/theme/trace_typography.dart';
import '../../tasks/domain/task.dart';
import '../../tasks/domain/task_status.dart';
import '../../tasks/utils/task_display_format.dart';

enum ScheduleTileVariant { archived, active, upcoming }

class ScheduleTaskTile extends StatelessWidget {
  const ScheduleTaskTile({
    super.key,
    required this.task,
    required this.variant,
    this.onTap,
  });

  final Task task;
  final ScheduleTileVariant variant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      ScheduleTileVariant.archived => _ArchivedTile(task: task, onTap: onTap),
      ScheduleTileVariant.active => _ActiveTile(task: task, onTap: onTap),
      ScheduleTileVariant.upcoming => _UpcomingTile(task: task, onTap: onTap),
    };
  }
}

class _ArchivedTile extends StatelessWidget {
  const _ArchivedTile({required this.task, this.onTap});

  final Task task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDone = task.status == TaskStatus.completed;
    final badge = isDone ? 'Done' : 'Failed';

    return _ScheduleCard(
      onTap: onTap,
      background: TraceColors.surfaceDim.withValues(alpha: 0.4),
      borderColor: TraceColors.surfaceContainerHighest,
      padding: TraceSpacing.md,
      opacity: 0.5,
      child: Stack(
        children: [
          Opacity(
            opacity: 0.88,
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
                          color: TraceColors.secondary,
                          decoration: isDone
                              ? TextDecoration.lineThrough
                              : null,
                          decorationThickness: 1,
                        ),
                      ),
                    ),
                    _Badge(label: badge, outlined: true),
                  ],
                ),
                const SizedBox(height: TraceSpacing.xs),
                Text(
                  '${TaskDisplayFormat.scheduleTimeRange(task)} • ${task.project}',
                  style: TraceTypography.labelSMono.copyWith(
                    color: TraceColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          if (isDone)
            Positioned(
              top: 0,
              right: 0,
              child: Icon(
                Icons.check_circle_outlined,
                size: 16,
                color: TraceColors.secondary,
              ),
            ),
        ],
      ),
    );
  }
}

class _ActiveTile extends StatelessWidget {
  const _ActiveTile({required this.task, this.onTap});

  final Task task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _ScheduleCard(
      onTap: onTap,
      background: TraceColors.surfaceContainerLowest,
      borderColor: TraceColors.primary.withValues(alpha: 0.2),
      padding: TraceSpacing.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  task.name,
                  style: TraceTypography.headlineSm.copyWith(
                    fontSize: 18,
                    height: 24 / 18,
                    color: TraceColors.onSurface,
                  ),
                ),
              ),
              _Badge(label: 'ACTIVE', filled: true),
            ],
          ),
          const SizedBox(height: TraceSpacing.sm),
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: TraceColors.primary),
              const SizedBox(width: TraceSpacing.sm),
              Text(
                TaskDisplayFormat.scheduleTimeRange(task),
                style: TraceTypography.labelMMMono.copyWith(
                  color: TraceColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (task.description != null && task.description!.isNotEmpty) ...[
            const SizedBox(height: TraceSpacing.sm),
            Text(
              task.description!,
              style: TraceTypography.bodyMd.copyWith(color: TraceColors.secondary),
            ),
          ],
          const SizedBox(height: TraceSpacing.sm),
          Text(
            task.project,
            style: TraceTypography.labelSMono.copyWith(color: TraceColors.secondary),
          ),
        ],
      ),
    );
  }
}

class _UpcomingTile extends StatelessWidget {
  const _UpcomingTile({required this.task, this.onTap});

  final Task task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final lead = TaskDisplayFormat.scheduleRelativeLead(task);

    return _ScheduleCard(
      onTap: onTap,
      background: TraceColors.surfaceContainerLowest,
      borderColor: TraceColors.surfaceContainer,
      padding: TraceSpacing.md,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.name, style: TraceTypography.titleS),
                const SizedBox(height: 2),
                Text(
                  '${TaskDisplayFormat.scheduleTimeRange(task)} • ${task.project}',
                  style: TraceTypography.labelSMono.copyWith(
                    color: TraceColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          if (lead.isNotEmpty)
            Text(
              lead,
              style: TraceTypography.labelSMono.copyWith(
                fontSize: 10,
                color: TraceColors.secondary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.child,
    required this.background,
    required this.borderColor,
    required this.padding,
    this.onTap,
    this.opacity = 1,
  });

  final Widget child;
  final Color background;
  final Color borderColor;
  final double padding;
  final VoidCallback? onTap;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(TraceSpacing.radiusDefault),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TraceSpacing.radiusDefault),
          child: Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(TraceSpacing.radiusDefault),
              border: Border.all(color: borderColor),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    this.filled = false,
    this.outlined = false,
  });

  final String label;
  final bool filled;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: filled ? TraceColors.primary : null,
        borderRadius: BorderRadius.circular(TraceSpacing.radiusSm),
        border: outlined
            ? Border.all(color: TraceColors.outlineVariant)
            : null,
      ),
      child: Text(
        label.toUpperCase(),
        style: TraceTypography.labelSMono.copyWith(
          fontSize: 9,
          color: filled ? TraceColors.onPrimary : TraceColors.secondary,
        ),
      ),
    );
  }
}
