import 'package:uuid/uuid.dart';

import 'task_constants.dart';
import 'task_priority.dart';
import 'task_status.dart';

class Task {
  const Task({
    required this.id,
    required this.name,
    required this.deadline,
    required this.project,
    required this.priority,
    required this.tags,
    required this.status,
    required this.createdAt,
    this.description,
    this.startTime,
    this.completedAt,
    this.failedAt,
    this.completionNote,
    this.failureNote,
  });

  final String id;
  final String name;
  final String? description;
  final DateTime? startTime;
  final DateTime deadline;
  final String project;
  final TaskPriority priority;
  final List<String> tags;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? failedAt;
  final String? completionNote;
  final String? failureNote;

  String? get outcomeNote =>
      status == TaskStatus.completed ? completionNote : failureNote;

  String get entryId => id.replaceAll('-', '').substring(0, 8).toUpperCase();

  bool get isArchived =>
      status == TaskStatus.completed || status == TaskStatus.failed;

  /// When [startTime] is unset, the task begins at creation time.
  DateTime get effectiveStartTime => startTime ?? createdAt;

  factory Task.create({
    required String name,
    required DateTime deadline,
    String? description,
    DateTime? startTime,
    String project = TaskConstants.defaultProject,
    TaskPriority priority = TaskPriority.medium,
    List<String> tags = const [],
  }) {
    final now = DateTime.now();
    return Task(
      id: const Uuid().v4(),
      name: name.trim(),
      description: description?.trim().isEmpty ?? true ? null : description!.trim(),
      startTime: startTime,
      deadline: deadline,
      project: project,
      priority: priority,
      tags: List.unmodifiable(tags.map((t) => t.trim().toUpperCase()).where((t) => t.isNotEmpty)),
      status: resolveInitialStatus(startTime: startTime, deadline: deadline, now: now),
      createdAt: now,
    );
  }

  static TaskStatus resolveInitialStatus({
    required DateTime? startTime,
    required DateTime deadline,
    required DateTime now,
  }) {
    if (deadline.isBefore(now)) {
      return TaskStatus.failed;
    }
    final effectiveStart = startTime ?? now;
    if (!effectiveStart.isAfter(now)) {
      return TaskStatus.current;
    }
    return TaskStatus.upcoming;
  }

  Task copyWith({
    String? name,
    String? description,
    DateTime? startTime,
    DateTime? deadline,
    String? project,
    TaskPriority? priority,
    List<String>? tags,
    TaskStatus? status,
    DateTime? completedAt,
    DateTime? failedAt,
    String? completionNote,
    String? failureNote,
    bool clearCompletedAt = false,
    bool clearFailedAt = false,
    bool clearCompletionNote = false,
    bool clearFailureNote = false,
  }) {
    return Task(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      deadline: deadline ?? this.deadline,
      project: project ?? this.project,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      createdAt: createdAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      failedAt: clearFailedAt ? null : (failedAt ?? this.failedAt),
      completionNote:
          clearCompletionNote ? null : (completionNote ?? this.completionNote),
      failureNote: clearFailureNote ? null : (failureNote ?? this.failureNote),
    );
  }
}
