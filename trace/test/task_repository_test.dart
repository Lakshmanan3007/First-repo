import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:trace/features/tasks/data/task_hive_adapter.dart';
import 'package:trace/features/tasks/data/task_repository.dart';
import 'package:trace/features/tasks/domain/task_constants.dart';
import 'package:trace/features/tasks/domain/task_priority.dart';
import 'package:trace/features/tasks/domain/task_status.dart';

void main() {
  late Directory tempDir;
  late TaskRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('trace_hive_test');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskAdapter());
    }
    repository = await TaskRepository.open();
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk(TaskConstants.boxName);
    await tempDir.delete(recursive: true);
  });

  test('markCompleted moves active task to completed archive', () async {
    final task = await repository.create(
      name: 'Ship release',
      deadline: DateTime.now().add(const Duration(days: 2)),
      priority: TaskPriority.high,
    );

    final completed = await repository.markCompleted(task.id);
    expect(completed.status, TaskStatus.completed);
    expect(completed.completedAt, isNotNull);
    expect(repository.getByStatus(TaskStatus.completed), hasLength(1));
  });

  test('reattemptFailed reopens task into active queue', () async {
    final task = await repository.create(
      name: 'Retry flow',
      deadline: DateTime.now().subtract(const Duration(hours: 1)),
      priority: TaskPriority.medium,
    );

    expect(task.status, TaskStatus.failed);

    final reopened = await repository.reattemptFailed(task.id);
    expect(reopened.status, isNot(TaskStatus.failed));
    expect(reopened.status, isNot(TaskStatus.completed));
    expect(reopened.failedAt, isNull);
    expect(reopened.deadline.isAfter(DateTime.now()), isTrue);
  });
}
