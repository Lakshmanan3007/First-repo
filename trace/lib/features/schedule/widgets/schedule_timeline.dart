import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/trace_colors.dart';
import '../../../core/theme/trace_spacing.dart';
import '../../../core/theme/trace_typography.dart';
import '../../tasks/domain/task.dart';
import '../domain/schedule_day_plan.dart';
import '../utils/schedule_planner.dart';
import 'schedule_task_tile.dart';

enum _TimelineNodeStyle { archived, active, upcoming }

class ScheduleTimeline extends StatelessWidget {
  const ScheduleTimeline({
    super.key,
    required this.plan,
    required this.selectedDay,
    required this.onTaskTap,
    this.tomorrowExpanded = false,
    this.onTomorrowToggle,
  });

  final ScheduleDayPlan plan;
  final DateTime selectedDay;
  final ValueChanged<Task> onTaskTap;
  final bool tomorrowExpanded;
  final VoidCallback? onTomorrowToggle;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    if (plan.archived.isNotEmpty) {
      final headerTime = _formatSectionTime(
        SchedulePlanner.archiveTimestamp(plan.archived.first)!,
      );
      children.add(
        _TimelineSection(
          style: _TimelineNodeStyle.archived,
          header: 'Archived / $headerTime',
          headerColor: TraceColors.secondary,
          children: plan.archived
              .map(
                (task) => ScheduleTaskTile(
                  task: task,
                  variant: ScheduleTileVariant.archived,
                  onTap: () => onTaskTap(task),
                ),
              )
              .toList(),
        ),
      );
    }

    if (plan.inFocus.isNotEmpty) {
      children.add(
        _TimelineSection(
          style: _TimelineNodeStyle.active,
          header: 'In Focus / Now',
          headerColor: TraceColors.primary,
          headerBold: true,
          children: plan.inFocus
              .map(
                (task) => ScheduleTaskTile(
                  task: task,
                  variant: ScheduleTileVariant.active,
                  onTap: () => onTaskTap(task),
                ),
              )
              .toList(),
        ),
      );
    }

    if (plan.queue.isNotEmpty) {
      final lead = SchedulePlanner.effectiveStart(plan.queue.first);
      children.add(
        _TimelineSection(
          style: _TimelineNodeStyle.upcoming,
          header: 'Queue / ${_formatSectionTime(lead)}',
          headerColor: TraceColors.secondary,
          children: plan.queue
              .map(
                (task) => ScheduleTaskTile(
                  task: task,
                  variant: ScheduleTileVariant.upcoming,
                  onTap: () => onTaskTap(task),
                ),
              )
              .toList(),
        ),
      );
    }

    if (plan.tomorrowPreview.isNotEmpty && onTomorrowToggle != null) {
      final tomorrow = SchedulePlanner.dateOnly(selectedDay)
          .add(const Duration(days: 1));
      final tomorrowLabel = DateFormat('d MMM').format(tomorrow);

      children.add(
        Padding(
          padding: const EdgeInsets.only(top: TraceSpacing.xl, bottom: TraceSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: onTomorrowToggle,
                child: Row(
                  children: [
                    Text(
                      'Tomorrow • $tomorrowLabel',
                      style: TraceTypography.labelMMMono.copyWith(
                        fontSize: 11,
                        letterSpacing: 0.08 * 11,
                      ),
                    ),
                    const SizedBox(width: TraceSpacing.md),
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: TraceColors.outlineVariant,
                              style: BorderStyle.solid,
                            ),
                          ),
                        ),
                        child: CustomPaint(
                          painter: _DashedLinePainter(),
                          child: const SizedBox(height: 1),
                        ),
                      ),
                    ),
                    Icon(
                      tomorrowExpanded
                          ? Icons.unfold_less
                          : Icons.unfold_more,
                      size: 18,
                      color: TraceColors.secondary,
                    ),
                  ],
                ),
              ),
              if (tomorrowExpanded) ...[
                const SizedBox(height: TraceSpacing.md),
                ...plan.tomorrowPreview.map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(bottom: TraceSpacing.sm),
                    child: ScheduleTaskTile(
                      task: task,
                      variant: ScheduleTileVariant.upcoming,
                      onTap: () => onTaskTap(task),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  String _formatSectionTime(DateTime time) => DateFormat('HH:mm').format(time);
}

class _TimelineSection extends StatelessWidget {
  const _TimelineSection({
    required this.style,
    required this.header,
    required this.headerColor,
    required this.children,
    this.headerBold = false,
  });

  final _TimelineNodeStyle style;
  final String header;
  final Color headerColor;
  final List<Widget> children;
  final bool headerBold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TraceSpacing.lg),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 24,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 14,
                    bottom: 0,
                    left: 7,
                    child: CustomPaint(
                      size: const Size(1, double.infinity),
                      painter: _DottedTimelinePainter(),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 4.5,
                    child: _TimelineNodeDot(style: style),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    header.toUpperCase(),
                    style: TraceTypography.labelSMono.copyWith(
                      fontSize: 10,
                      letterSpacing: 0.12 * 10,
                      color: headerColor,
                      fontWeight: headerBold ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: TraceSpacing.md),
                  ...children
                      .expand(
                        (child) => [
                          child,
                          const SizedBox(height: TraceSpacing.md),
                        ],
                      )
                      .toList()
                    ..removeLast(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineNodeDot extends StatelessWidget {
  const _TimelineNodeDot({required this.style});

  final _TimelineNodeStyle style;

  @override
  Widget build(BuildContext context) {
    final borderWidth = style == _TimelineNodeStyle.active ? 2.0 : 1.0;
    final borderColor = switch (style) {
      _TimelineNodeStyle.archived => TraceColors.outlineVariant,
      _TimelineNodeStyle.active => TraceColors.primary,
      _TimelineNodeStyle.upcoming => TraceColors.outline,
    };
    final fillColor = switch (style) {
      _TimelineNodeStyle.archived => TraceColors.outlineVariant,
      _TimelineNodeStyle.active => TraceColors.primary,
      _TimelineNodeStyle.upcoming => TraceColors.outline,
    };

    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        color: TraceColors.background,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: fillColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _DottedTimelinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashHeight = 4.0;
    const gap = 4.0;
    final paint = Paint()
      ..color = TraceColors.outlineVariant
      ..strokeWidth = 1;

    var y = 0.0;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(0, y + dashHeight), paint);
      y += dashHeight + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 4.0;
    final paint = Paint()
      ..color = TraceColors.outlineVariant
      ..strokeWidth = 1;

    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth * 2;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
