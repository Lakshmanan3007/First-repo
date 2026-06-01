import 'package:flutter_test/flutter_test.dart';
import 'package:trace/features/activity/domain/activity_event.dart';
import 'package:trace/features/activity/utils/activity_journal_builder.dart';
import 'package:trace/features/tasks/domain/task.dart';
import 'package:trace/features/tasks/domain/task_priority.dart';
import 'package:trace/features/tasks/domain/task_status.dart';

void main() {
  final now = DateTime(2026, 5, 31, 14);

  test('computes health from completed vs failed in window', () {
    final tasks = [
      Task(
        id: '1',
        name: 'Done',
        deadline: now,
        project: 'General Work',
        priority: TaskPriority.medium,
        tags: const [],
        status: TaskStatus.completed,
        createdAt: now.subtract(const Duration(days: 1)),
        completedAt: now.subtract(const Duration(hours: 2)),
      ),
      Task(
        id: '2',
        name: 'Missed',
        deadline: now,
        project: 'General Work',
        priority: TaskPriority.medium,
        tags: const [],
        status: TaskStatus.failed,
        createdAt: now.subtract(const Duration(days: 1)),
        failedAt: now.subtract(const Duration(hours: 1)),
      ),
    ];

    final journal = ActivityJournalBuilder.build(tasks: tasks, now: now);
    expect(journal.metrics.healthPercent, 50);
    expect(journal.metrics.loadJobs, 2);
  });

  test('groups batch creation when multiple tasks share an hour', () {
    final created = DateTime(2026, 5, 31, 8, 15);
    final tasks = List.generate(
      3,
      (index) => Task(
        id: '$index',
        name: 'Job $index',
        deadline: now.add(const Duration(days: 1)),
        project: 'Ops',
        priority: TaskPriority.low,
        tags: const [],
        status: TaskStatus.upcoming,
        createdAt: created.add(Duration(minutes: index)),
      ),
    );

    final journal = ActivityJournalBuilder.build(tasks: tasks, now: now);
    final todayEvents = journal.dayGroups
        .firstWhere((g) => g.isToday)
        .events;

    expect(
      todayEvents.any((e) => e.kind == ActivityEventKind.batchCreated),
      isTrue,
    );
  });

  test('emits completion journal entry with operational title', () {
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
    );

    final journal = ActivityJournalBuilder.build(tasks: [task], now: now);
    final completedEvents = journal.dayGroups
        .expand((g) => g.events)
        .where((e) => e.kind == ActivityEventKind.taskCompleted);

    expect(completedEvents, hasLength(1));
    expect(completedEvents.first.title, 'UI_POLISH');
  });
}
