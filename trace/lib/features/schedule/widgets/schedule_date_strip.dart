import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/trace_colors.dart';
import '../../../core/theme/trace_spacing.dart';
import '../../../core/theme/trace_typography.dart';
import '../utils/schedule_planner.dart';

class ScheduleDateStrip extends StatelessWidget {
  const ScheduleDateStrip({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
  });

  final DateTime selectedDay;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final days = SchedulePlanner.weekStripAround(selectedDay);
    final monthLabel = DateFormat('MMMM yyyy').format(selectedDay);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TraceSpacing.marginMobile,
        TraceSpacing.md,
        TraceSpacing.marginMobile,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(monthLabel, style: TraceTypography.titleS),
              Icon(
                Icons.calendar_today_outlined,
                size: 20,
                color: TraceColors.secondary,
              ),
            ],
          ),
          const SizedBox(height: TraceSpacing.sm),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: TraceSpacing.xs),
              itemBuilder: (context, index) {
                final day = days[index];
                final isSelected = SchedulePlanner.isSameDay(day, selectedDay);
                final weekday = DateFormat('EEE').format(day).toUpperCase();
                final dayNum = DateFormat('d').format(day);

                return GestureDetector(
                  onTap: () => onDaySelected(day),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 54,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? TraceColors.primary
                          : TraceColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(TraceSpacing.radiusDefault),
                      border: isSelected
                          ? Border.all(color: TraceColors.primary, width: 2)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: TraceColors.primary.withValues(alpha: 0.12),
                                blurRadius: 0,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          weekday,
                          style: TraceTypography.labelSMono.copyWith(
                            color: isSelected
                                ? TraceColors.onPrimary.withValues(alpha: 0.7)
                                : TraceColors.secondary,
                          ),
                        ),
                        const SizedBox(height: TraceSpacing.xs),
                        Text(
                          dayNum,
                          style: TraceTypography.labelMMMono.copyWith(
                            fontSize: 18,
                            color: isSelected
                                ? TraceColors.onPrimary
                                : TraceColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
