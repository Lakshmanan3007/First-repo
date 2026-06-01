import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace/features/notifications/data/notification_state_store.dart';
import 'package:trace/features/notifications/domain/notification_preferences.dart';
import 'package:trace/features/notifications/domain/trace_notification.dart';
import 'package:trace/features/notifications/services/notification_coordinator.dart';
import 'package:trace/features/tasks/domain/task.dart';
import 'package:trace/features/tasks/domain/task_priority.dart';
import 'package:trace/features/tasks/domain/task_status.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late NotificationStateStore store;
  late NotificationCoordinator coordinator;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = await NotificationStateStore.create();
    coordinator = NotificationCoordinator(store);
  });

  test('emits active alert when task transitions to current', () async {
    final now = DateTime(2026, 5, 31, 12);
    final task = Task(
      id: 't1',
      name: 'Deploy',
      deadline: now.add(const Duration(days: 1)),
      project: 'Ops',
      priority: TaskPriority.high,
      tags: const [],
      status: TaskStatus.upcoming,
      createdAt: now.subtract(const Duration(hours: 1)),
    );

    await coordinator.evaluate(
      tasks: [task],
      preferences: NotificationPreferences.defaults,
      now: now,
    );

    final activeTask = task.copyWith(status: TaskStatus.current);
    final alerts = await coordinator.evaluate(
      tasks: [activeTask],
      preferences: NotificationPreferences.defaults,
      now: now,
    );

    expect(
      alerts.any((a) => a.type == TraceNotificationType.taskActive),
      isTrue,
    );
  });

  test('emits deadline alert inside warning window', () async {
    final now = DateTime(2026, 5, 31, 12);
    final task = Task(
      id: 't2',
      name: 'Review',
      deadline: now.add(const Duration(minutes: 8)),
      project: 'Design',
      priority: TaskPriority.medium,
      tags: const [],
      status: TaskStatus.current,
      createdAt: now.subtract(const Duration(hours: 2)),
    );

    await store.setLastStatus(task.id, TaskStatus.current);

    final alerts = await coordinator.evaluate(
      tasks: [task],
      preferences: NotificationPreferences.defaults,
      now: now,
    );

    expect(
      alerts.any((a) => a.type == TraceNotificationType.deadlineApproaching),
      isTrue,
    );
  });
}
