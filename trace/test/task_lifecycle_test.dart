import 'package:flutter_test/flutter_test.dart';
import 'package:trace/features/tasks/domain/task.dart';
import 'package:trace/features/tasks/domain/task_lifecycle.dart';
import 'package:trace/features/tasks/domain/task_priority.dart';
import 'package:trace/features/tasks/domain/task_status.dart';

void main() {
  test('upcoming transitions to current when start time arrives', () {
    final now = DateTime(2026, 5, 31, 12);
    final task = Task(
      id: 'id',
      name: 'Test',
      deadline: now.add(const Duration(days: 2)),
      project: 'General Work',
      priority: TaskPriority.medium,
      tags: const [],
      status: TaskStatus.upcoming,
      createdAt: now.subtract(const Duration(days: 1)),
      startTime: now.subtract(const Duration(minutes: 5)),
    );

    final updated = TaskLifecycle.applyTransition(task, now: now);
    expect(updated.status, TaskStatus.current);
  });

  test('active task transitions to failed when deadline passes', () {
    final now = DateTime(2026, 5, 31, 12);
    final task = Task(
      id: 'id',
      name: 'Test',
      deadline: now.subtract(const Duration(hours: 1)),
      project: 'General Work',
      priority: TaskPriority.medium,
      tags: const [],
      status: TaskStatus.current,
      createdAt: now.subtract(const Duration(days: 1)),
    );

    final updated = TaskLifecycle.applyTransition(task, now: now);
    expect(updated.status, TaskStatus.failed);
    expect(updated.failedAt, isNotNull);
  });

  test('completed tasks remain completed during sync', () {
    final now = DateTime(2026, 5, 31, 12);
    final task = Task(
      id: 'id',
      name: 'Test',
      deadline: now.subtract(const Duration(days: 1)),
      project: 'General Work',
      priority: TaskPriority.medium,
      tags: const [],
      status: TaskStatus.completed,
      createdAt: now.subtract(const Duration(days: 2)),
      completedAt: now.subtract(const Duration(days: 1)),
    );

    final updated = TaskLifecycle.applyTransition(task, now: now);
    expect(updated.status, TaskStatus.completed);
  });
}
