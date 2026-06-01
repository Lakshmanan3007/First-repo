import 'package:flutter/material.dart';

import '../../../core/theme/trace_colors.dart';
import '../../../core/theme/trace_spacing.dart';
import '../../../core/theme/trace_typography.dart';
import '../domain/task_status.dart';

class TaskStatusTabs extends StatelessWidget {
  const TaskStatusTabs({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final TaskStatus selected;
  final ValueChanged<TaskStatus> onSelected;

  static const _tabs = [
    TaskStatus.current,
    TaskStatus.upcoming,
    TaskStatus.completed,
    TaskStatus.failed,
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TraceSpacing.marginMobile,
        0,
        TraceSpacing.marginMobile,
        TraceSpacing.md,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _tabs.map((status) {
            final isSelected = status == selected;
            return Padding(
              padding: const EdgeInsets.only(right: TraceSpacing.md),
              child: InkWell(
                onTap: () => onSelected(status),
                child: Container(
                  padding: const EdgeInsets.only(bottom: TraceSpacing.sm),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected
                            ? TraceColors.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    status.label,
                    style: TraceTypography.labelMMMono.copyWith(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? TraceColors.primary
                          : TraceColors.secondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
