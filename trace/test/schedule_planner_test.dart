import 'package:flutter_test/flutter_test.dart';
import 'package:trace/features/schedule/utils/schedule_planner.dart';
import 'package:trace/features/tasks/domain/task.dart';
import 'package:trace/features/tasks/domain/task_priority.dart';
import 'package:trace/features/tasks/domain/task_status.dart';

void main() {
  final now = DateTime(2026, 5, 31, 12);

  test('groups current task into in-focus on today', () {
    final task = Task(
      id: '1',
      name: 'Active work',
      deadline: now.add(const Duration(hours: 3)),
      project: 'General Work',
      priority: TaskPriority.medium,
      tags: const [],
      status: TaskStatus.current,
      createdAt: now.subtract(const Duration(hours: 2)),
      startTime: now.subtract(const Duration(hours: 1)),
    );

    final plan = SchedulePlanner.build(
      tasks: [task],
      selectedDay: now,
      now: now,
    );

    expect(plan.inFocus, hasLength(1));
    expect(plan.queue, isEmpty);
  });

  test('places completed task in archived for completion day', () {
    final completedAt = DateTime(2026, 5, 30, 9);
    final task = Task(
      id: '2',
      name: 'Shipped',
      deadline: completedAt,
      project: 'General Work',
      priority: TaskPriority.low,
      tags: const [],
      status: TaskStatus.completed,
      createdAt: completedAt.subtract(const Duration(days: 1)),
      completedAt: completedAt,
    );

    final plan = SchedulePlanner.build(
      tasks: [task],
      selectedDay: completedAt,
      now: now,
    );

    expect(plan.archived, hasLength(1));
    expect(plan.inFocus, isEmpty);
  });

  test('lists upcoming tasks in queue when they overlap selected day', () {
    final task = Task(
      id: '3',
      name: 'Later',
      deadline: now.add(const Duration(hours: 5)),
      project: 'Ops',
      priority: TaskPriority.medium,
      tags: const [],
      status: TaskStatus.upcoming,
      createdAt: now,
      startTime: now.add(const Duration(hours: 2)),
    );

    final plan = SchedulePlanner.build(
      tasks: [task],
      selectedDay: now,
      now: now,
    );

    expect(plan.queue, hasLength(1));
  });
}
