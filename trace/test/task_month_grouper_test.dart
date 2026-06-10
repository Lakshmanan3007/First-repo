import 'package:flutter_test/flutter_test.dart';
import 'package:trace/features/tasks/domain/task.dart';
import 'package:trace/features/tasks/domain/task_priority.dart';
import 'package:trace/features/tasks/domain/task_status.dart';
import 'package:trace/features/tasks/utils/task_month_grouper.dart';

void main() {
  test('groups completed tasks by month', () {
    final tasks = [
      Task(
        id: '1',
        name: 'June task',
        deadline: DateTime(2026, 6, 15),
        project: 'Work',
        priority: TaskPriority.medium,
        tags: const [],
        status: TaskStatus.completed,
        createdAt: DateTime(2026, 6, 1),
        completedAt: DateTime(2026, 6, 10),
      ),
      Task(
        id: '2',
        name: 'May task',
        deadline: DateTime(2026, 5, 20),
        project: 'Work',
        priority: TaskPriority.medium,
        tags: const [],
        status: TaskStatus.completed,
        createdAt: DateTime(2026, 5, 1),
        completedAt: DateTime(2026, 5, 28),
      ),
    ];

    final groups = TaskMonthGrouper.group(tasks, TaskStatus.completed);

    expect(groups, hasLength(2));
    expect(groups.first.label, 'June 2026');
    expect(groups.first.tasks, hasLength(1));
    expect(groups.last.label, 'May 2026');
  });
}
