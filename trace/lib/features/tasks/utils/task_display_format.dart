import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/trace_colors.dart';
import '../domain/task.dart';
import '../domain/task_priority.dart';
import '../domain/task_status.dart';

abstract final class TaskDisplayFormat {
  static String projectTag(Task task) {
    return task.project.replaceAll(' ', '_').toUpperCase();
  }

  static Color indicatorColor(Task task) {
    if (task.status == TaskStatus.failed) return TraceColors.error;
    return switch (task.priority) {
      TaskPriority.high => TraceColors.error,
      TaskPriority.medium => const Color(0xFFEAB308),
      TaskPriority.low => TraceColors.primary,
    };
  }

  static Color priorityTextColor(Task task) {
    return switch (task.priority) {
      TaskPriority.high => TraceColors.error,
      TaskPriority.medium => TraceColors.secondary,
      TaskPriority.low => TraceColors.outline,
    };
  }

  static String timeLabel(Task task, {DateTime? now}) {
    final effectiveNow = now ?? DateTime.now();
    final remaining = task.deadline.difference(effectiveNow);

    if (remaining.isNegative) {
      return 'OVERDUE';
    }

    if (remaining.inHours < 24) {
      final hours = remaining.inHours;
      final minutes = remaining.inMinutes.remainder(60);
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')} REMAINING';
    }

    final days = remaining.inDays;
    if (days == 1) return '01 DAY LEFT';
    return '${days.toString().padLeft(2, '0')} DAYS LEFT';
  }

  static IconData timeIcon(Task task, {DateTime? now}) {
    final effectiveNow = now ?? DateTime.now();
    final remaining = task.deadline.difference(effectiveNow);

    if (remaining.inHours < 24) {
      return Icons.timer_outlined;
    }
    return Icons.event_outlined;
  }

  static bool timeIsUrgent(Task task, {DateTime? now}) {
    final effectiveNow = now ?? DateTime.now();
    return task.deadline.difference(effectiveNow).inHours < 2;
  }

  static String scheduleTimeRange(Task task) {
    final start = task.startTime ?? task.createdAt;
    final formatter = DateFormat('HH:mm');
    return '${formatter.format(start)} — ${formatter.format(task.deadline)}';
  }

  static String scheduleRelativeLead(Task task, {DateTime? now}) {
    final effectiveNow = now ?? DateTime.now();
    final target = task.startTime ?? task.deadline;
    final remaining = target.difference(effectiveNow);
    if (!remaining.isNegative && remaining.inMinutes < 1) {
      return 'T-now';
    }
    if (remaining.isNegative) return '';

    if (remaining.inHours < 24) {
      final hours = remaining.inHours;
      if (hours < 1) {
        final minutes = remaining.inMinutes;
        return 'T-${minutes}m';
      }
      return 'T-${hours}h';
    }

    final days = remaining.inDays;
    return 'T-${days}d';
  }
}
