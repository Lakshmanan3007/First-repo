import 'package:flutter_test/flutter_test.dart';
import 'package:trace/features/activity/domain/activity_event.dart';
import 'package:trace/features/activity/utils/activity_journal_builder.dart';
import 'package:trace/features/tasks/domain/task.dart';
import 'package:trace/features/tasks/domain/task_priority.dart';
import 'package:trace/features/tasks/domain/task_status.dart';

void main() {
  final now = DateTime(2026, 6, 10, 14);

  test('builds today summary from active tasks', () {
    final tasks = [
      Task(
        id: '1',
        name: 'Active task',
        deadline: now.add(const Duration(hours: 2)),
        project: 'Work',
        priority: TaskPriority.medium,
        tags: const [],
        status: TaskStatus.current,
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      Task(
        id: '2',
        name: 'Done today',
        deadline: now,
        project: 'Work',
        priority: TaskPriority.medium,
        tags: const [],
        status: TaskStatus.completed,
        createdAt: now.subtract(const Duration(days: 1)),
        completedAt: now.subtract(const Duration(hours: 1)),
        completionNote: 'Shipped on time.',
      ),
    ];

    final journal = ActivityJournalBuilder.build(tasks: tasks, now: now);
    expect(journal.summary.currentCount, 1);
    expect(journal.summary.completedToday, 1);
  });

  test('places completion event in today timeline', () {
    final task = Task(
      id: 'c1',
      name: 'UI polish',
      deadline: now,
      project: 'Design',
      priority: TaskPriority.high,
      tags: const ['DESIGN'],
      status: TaskStatus.completed,
      createdAt: now.subtract(const Duration(hours: 4)),
      completedAt: now.subtract(const Duration(minutes: 30)),
      completionNote: 'Task completed successfully.',
    );

    final journal = ActivityJournalBuilder.build(tasks: [task], now: now);
    final today = journal.timeline.firstWhere((p) => p.label == 'Today');

    expect(today.events, hasLength(1));
    expect(today.events.first.kind, ActivityEventKind.taskCompleted);
    expect(today.events.first.title, 'UI polish');
    expect(today.events.first.body, 'Task completed successfully.');
  });

  test('lists upcoming transitions for scheduled tasks', () {
    final tasks = [
      Task(
        id: 'u1',
        name: 'Later task',
        deadline: now.add(const Duration(days: 2)),
        startTime: now.add(const Duration(hours: 3)),
        project: 'College',
        priority: TaskPriority.low,
        tags: const [],
        status: TaskStatus.upcoming,
        createdAt: now,
      ),
    ];

    final journal = ActivityJournalBuilder.build(tasks: tasks, now: now);
    expect(journal.upcomingTransitions, isNotEmpty);
    expect(journal.upcomingTransitions.first.taskName, 'Later task');
  });
}
