import 'task_priority.dart';

/// Optional prefill payload when opening the create-task screen.
class CreateTaskDraft {
  const CreateTaskDraft({
    this.name,
    this.description,
    this.project,
    this.priority,
    this.tags = const [],
  });

  final String? name;
  final String? description;
  final String? project;
  final TaskPriority? priority;
  final List<String> tags;
}
