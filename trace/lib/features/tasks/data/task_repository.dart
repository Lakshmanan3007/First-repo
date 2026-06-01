import 'package:hive/hive.dart';

import '../domain/task.dart';
import '../domain/task_constants.dart';
import '../domain/task_lifecycle.dart';
import '../domain/task_priority.dart';
import '../domain/task_status.dart';
import 'task_hive_adapter.dart';

class TaskRepository {
  TaskRepository(this._box);

  final Box<Task> _box;

  static Future<TaskRepository> open() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskAdapter());
    }
    final box = await Hive.openBox<Task>(TaskConstants.boxName);
    return TaskRepository(box);
  }

  List<Task> getAll() {
    return _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<Task> getByStatus(TaskStatus status) {
    return getAll().where((task) => task.status == status).toList();
  }

  List<Task> search({
    required TaskStatus status,
    String query = '',
  }) {
    final normalized = query.trim().toLowerCase();
    final tasks = getByStatus(status);

    if (normalized.isEmpty) return _sortForTab(status, tasks);

    final filtered = tasks.where((task) {
      final haystack = [
        task.name,
        task.description ?? '',
        task.project,
        ...task.tags,
      ].join(' ').toLowerCase();
      return haystack.contains(normalized);
    }).toList();

    return _sortForTab(status, filtered);
  }

  List<Task> _sortForTab(TaskStatus status, List<Task> tasks) {
    switch (status) {
      case TaskStatus.current:
        tasks.sort((a, b) => a.deadline.compareTo(b.deadline));
      case TaskStatus.upcoming:
        tasks.sort((a, b) {
          final aStart = a.startTime ?? a.deadline;
          final bStart = b.startTime ?? b.deadline;
          return aStart.compareTo(bStart);
        });
      case TaskStatus.completed:
      case TaskStatus.failed:
        tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return tasks;
  }

  /// Applies time-based transitions for non-completed tasks and persists changes.
  Future<void> syncLifecycleStatuses({DateTime? now}) async {
    final effectiveNow = now ?? DateTime.now();
    for (final task in _box.values.toList()) {
      final updated = TaskLifecycle.applyTransition(task, now: effectiveNow);
      if (updated != task) {
        await _box.put(updated.id, updated);
      }
    }
  }

  Task? getById(String id) => _box.get(id);

  Future<Task> create({
    required String name,
    required DateTime deadline,
    String? description,
    DateTime? startTime,
    String project = TaskConstants.defaultProject,
    TaskPriority priority = TaskPriority.medium,
    List<String> tags = const [],
  }) async {
    final task = Task.create(
      name: name,
      deadline: deadline,
      description: description,
      startTime: startTime,
      project: project,
      priority: priority,
      tags: tags,
    );
    await _box.put(task.id, task);
    return task;
  }

  Future<void> save(Task task) async {
    await _box.put(task.id, task);
  }

  Future<Task> markCompleted(String id) async {
    final task = _box.get(id);
    if (task == null) {
      throw StateError('Task not found');
    }
    if (task.status == TaskStatus.completed) return task;

    final now = DateTime.now();
    final updated = task.copyWith(
      status: TaskStatus.completed,
      completedAt: now,
    );
    await save(updated);
    return updated;
  }

  Future<Task> markFailed(String id) async {
    final task = _box.get(id);
    if (task == null) {
      throw StateError('Task not found');
    }
    if (task.status == TaskStatus.completed) {
      throw StateError('Completed tasks cannot be marked failed');
    }

    final now = DateTime.now();
    final updated = task.copyWith(
      status: TaskStatus.failed,
      failedAt: now,
    );
    await save(updated);
    return updated;
  }

  /// Resets a failed task into the active queue with a fresh deadline.
  Future<Task> reattemptFailed(String id) async {
    final task = _box.get(id);
    if (task == null) {
      throw StateError('Task not found');
    }
    if (task.status != TaskStatus.failed) {
      throw StateError('Only failed tasks can be reattempted');
    }

    final now = DateTime.now();
    final originalWindow = task.deadline.difference(task.createdAt);
    final fallbackWindow = originalWindow.inMinutes <= 0
        ? const Duration(days: 1)
        : originalWindow;
    var newDeadline = now.add(fallbackWindow);
    if (!newDeadline.isAfter(now)) {
      newDeadline = now.add(const Duration(days: 1));
    }

    final updated = task.copyWith(
      status: Task.resolveInitialStatus(
        startTime: task.startTime,
        deadline: newDeadline,
        now: now,
      ),
      deadline: newDeadline,
      clearCompletedAt: true,
      clearFailedAt: true,
    );
    await save(updated);
    return updated;
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}
